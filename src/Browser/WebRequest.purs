{-
    | Filtering, intercepting and modifying http and https requests.
    | [webRequest](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/webRequest)
-}
module Browser.WebRequest
    ( ResourceType (..)
    , RequestFilter, requestFilter, RequestFilterOpts
    , types, tabId, windowId, incognito

    , BeforeRequestBlockingEvent, onBeforeRequestBlocking
    , BeforeRequestEvent, onBeforeRequest
    , OnBeforeRequestDict (..), OnBeforeRequestDetails, BeforeRequestResponse

    , AuthRequiredResponse
    , BeforeSendHeadersResponse
    , HeadersReceivedResponse
    , class HasCancel
    , class HasRedirectUrl
    , authCredentials, cancel, redirectUrl, requestHeaders, responseHeaders
    , upgradeToSecure
    ) where

import Prelude
import Browser.Event (class Event)
import Control.Alternative (class Alternative, empty)
import Effect.Uncurried (EffectFn3, EffectFn1, runEffectFn3, mkEffectFn1)
import Data.Options (Option, Options, opt, options, (:=))
import Foreign (Foreign, unsafeToForeign)
import Data.Functor.Contravariant (cmap)


-- | Represents the context in which a resource was fetched in a web request
-- | [ResourceType](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/webRequest/ResourceType)
data ResourceType
    = Beacon
    | CspReport
    | Font
    | Image
    | Imageset
    | MainFrame
    | Media
    | Object
    | ObjectSubrequest
    | Ping
    | Script
    | Speculative
    | Stylesheet
    | SubFrame
    | WebManifest
    | Websocket
    | Xbl
    | XmlDtd
    | Xmlhttprequest
    | Xslt
    | Other
resourceTypeString :: ResourceType -> String
resourceTypeString rt = case rt of
    Beacon           -> "beacon"
    CspReport        -> "csp_report"
    Font             -> "font"
    Image            -> "image"
    Imageset         -> "imageset"
    MainFrame        -> "main_frame"
    Media            -> "media"
    Object           -> "object"
    ObjectSubrequest -> "object_subrequest"
    Ping             -> "ping"
    Script           -> "script"
    Speculative      -> "speculative"
    Stylesheet       -> "stylesheet"
    SubFrame         -> "sub_frame"
    WebManifest      -> "web_manifest"
    Websocket        -> "websocket"
    Xbl              -> "xbl"
    XmlDtd           -> "xml_dtd"
    Xmlhttprequest   -> "xmlhttprequest"
    Xslt             -> "xslt"
    Other            -> "other"
stringResourceType :: forall m. Alternative m
    => String -> m ResourceType
stringResourceType str = case str of
    "beacon"            -> pure Beacon
    "csp_report"        -> pure CspReport
    "font"              -> pure Font
    "image"             -> pure Image
    "imageset"          -> pure Imageset
    "main_frame"        -> pure MainFrame
    "media"             -> pure Media
    "object"            -> pure Object
    "object_subrequest" -> pure ObjectSubrequest
    "ping"              -> pure Ping
    "script"            -> pure Script
    "speculative"       -> pure Speculative
    "stylesheet"        -> pure Stylesheet
    "sub_frame"         -> pure SubFrame
    "web_manifest"      -> pure WebManifest
    "websocket"         -> pure Websocket
    "xbl"               -> pure Xbl
    "xml_dtd"           -> pure XmlDtd
    "xmlhttprequest"    -> pure Xmlhttprequest
    "xslt"              -> pure Xslt
    "other"             -> pure Other
    _ -> empty


-- | Describes which filters to apply to webRequest events. Construct instances
-- | of this type with `requestFilter`
-- | [RequestFilter](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/webRequest/RequestFilter)
newtype RequestFilter = RequestFilter (Options RequestFilterOpts)

-- | Constuctor of `RequestFilter`
requestFilter :: Array String -- ^ Match patterns; events will only trigger
                              -- ^ when they match
              -> Options RequestFilterOpts -- ^ Other options, see below
              -> RequestFilter
requestFilter urls opts =
    let opts' = opts <> (urlsOption := urls)
    in RequestFilter opts'

-- | Optional parameters for RequestFilter
data RequestFilterOpts
urlsOption :: Option RequestFilterOpts (Array String)
urlsOption =  opt "urls"
types      :: Option RequestFilterOpts (Array ResourceType)
types      =  cmap (map resourceTypeString) $ opt "types"
tabId      :: Option RequestFilterOpts Int
tabId      =  opt "tabId"
windowId   :: Option RequestFilterOpts Int
windowId   =  opt "windowId"
incognito  :: Option RequestFilterOpts Boolean
incognito  =  opt "incognito"


-- | ## onBeforeRequest and its types

-- | Argument of event callback
newtype OnBeforeRequestDetails = OnBeforeRequestDetails OnBeforeRequestDict
type OnBeforeRequestDict =
    { documentUrl :: String
    , frameAncestors :: Array {url :: String, frameId :: Int}
    , frameId :: Int
    , method :: String
    , originUrl :: String
    , parentFrameId :: Int
    -- , proxyInfo :: Big optional type
    -- , requestBody :: Big optional type
    , requestId :: String
    , tabId :: Int
    , thirdParty :: Boolean
    , timeStamp :: Number
    , type :: String -- ^ Stringified `ResourceType`
    , url :: String
    , urlClassification :: {firstParty :: Array String, thirdParty :: Array String}
    }

-- | Return type of event callback
data BeforeRequestResponse

-- | onBeforeRequest with a blocking callback. Being blocking allows it to
-- | cancel and redirect responses.
foreign import data BeforeRequestBlockingEvent :: Type
-- | Value of this type
foreign import onBeforeRequestBlocking :: BeforeRequestBlockingEvent
instance beforeRequestBlockingEvent
    :: Event BeforeRequestBlockingEvent -- event type
             RequestFilter -- event params
             OnBeforeRequestDetails -- callback argument
             (Options BeforeRequestResponse) -- callback return type
             where
    addListener _event (RequestFilter opts) callback =
        let filter = options opts
            validateArgs = OnBeforeRequestDetails
            validateRet = options
            wrappedCallback = mkEffectFn1 (map validateRet <<< callback <<< validateArgs)
        in runEffectFn3 addBeforeRequestListener_ filter wrappedCallback ["blocking"]

-- | onBeforeRequest with a non-blocking callback. Being non-blocking allows it
-- | to only see requests, but not react to them
foreign import data BeforeRequestEvent :: Type
-- | Value of this type
foreign import onBeforeRequest :: BeforeRequestEvent
instance beforeRequestEvent
    :: Event BeforeRequestEvent -- event type
             RequestFilter -- event params
             OnBeforeRequestDetails -- callback argument
             Unit -- callback return type
             where
    addListener _event (RequestFilter opts) callback =
        let filter = options opts
            validateArgs = OnBeforeRequestDetails
            validateRet = const $ unsafeToForeign {}
            wrappedCallback = mkEffectFn1 (map validateRet <<< callback <<< validateArgs)
        in runEffectFn3 addBeforeRequestListener_ filter wrappedCallback []

foreign import addBeforeRequestListener_
    :: EffectFn3 Foreign
                 (EffectFn1 OnBeforeRequestDict Foreign)
                 (Array String)
                 Unit


data AuthRequiredResponse
data BeforeSendHeadersResponse
data HeadersReceivedResponse

-- | ## BlockingResponse categories
-- | Request handlers can return various types of BlockingResponse, and each
-- | blocking response can have missing options. So we create classes: where
-- | each option is even allowed to be present.

-- | For responses that have `cancel` field
class HasCancel a
instance      cancelBeforeRequest     :: HasCancel BeforeRequestResponse
else instance cancelBeforeSendHeaders :: HasCancel BeforeSendHeadersResponse
else instance cancelHeadersReceived   :: HasCancel HeadersReceivedResponse
else instance cancelAuthRequired      :: HasCancel AuthRequiredResponse

-- | For responses that have `redirect` field
class HasRedirectUrl a
instance      redirectUrlBeforeRequest :: HasRedirectUrl BeforeRequestResponse
else instance redirectHeadersReceived  :: HasRedirectUrl HeadersReceivedResponse

authCredentials :: Option AuthRequiredResponse
                          {username :: String, password :: String}
authCredentials = opt "authCredentials"

cancel :: forall a. HasCancel a => Option a Boolean
cancel = opt "cancel"

redirectUrl :: forall a. HasRedirectUrl a => Option a String
redirectUrl = opt "redirectUrl"

requestHeaders :: Option BeforeSendHeadersResponse
                         (Array {name :: String, value :: String}) -- TODO: binary
requestHeaders = opt "requestHeaders"

responseHeaders :: Option HeadersReceivedResponse
                          (Array {name :: String, value :: String}) -- TODO: binary
responseHeaders = opt "responseHeaders"

upgradeToSecure :: Option BeforeRequestResponse Boolean
upgradeToSecure = opt "upgradeToSecure"
