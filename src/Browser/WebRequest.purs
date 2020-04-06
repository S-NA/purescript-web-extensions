{-
    | Filtering, intercepting and modifying http and https requests.
    | [webRequest](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/webRequest)
    |
    | You can find an example extension using this API
    | [here](https://gist.github.com/d86leader/d4649e41b75e325e8e6ba41e1b628b73)
-}
module Browser.WebRequest
    ( ResourceType (..)
    , RequestFilter, requestFilter, RequestFilterOpts
    , types, tabId, windowId, incognito

    , BeforeRequestBlockingEvent, onBeforeRequestBlocking
    , BeforeRequestEvent, onBeforeRequest
    , OnBeforeRequestDetails (..), OnBeforeRequestDict (..), BeforeRequestResponse

    , BeforeSendHeadersBlockingEvent, onBeforeSendHeadersBlocking
    , OnBeforeSendHeadersDetails (..), OnBeforeSendHeadersDict (..)
    , BeforeSendHeadersResponse

    , AuthRequiredResponse
    , HeadersReceivedResponse
    , class HasCancel
    , class HasRedirectUrl
    , authCredentials, cancel, redirectUrl, requestHeaders, responseHeaders
    , upgradeToSecure
    ) where

import Prelude
import Browser.Event (class Event)
import Control.Alternative (class Alternative, empty)
import Effect.Uncurried (EffectFn4, EffectFn1, runEffectFn4, mkEffectFn1)
import Data.Options (Option, Options, opt, options, (:=))
import Foreign (Foreign, unsafeToForeign)
import Data.Functor.Contravariant (cmap)


-- | Represents the context in which a resource was fetched in a web request.
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
-- |
-- | Arguments:
-- |    - `Array String` - Match patterns; events will only trigger when they
-- |    match
-- |    - `Options RequestFilterOpts` - Other options, see below
requestFilter :: Array String
              -> Options RequestFilterOpts
              -> RequestFilter
requestFilter urls opts =
    let opts' = opts <> (urlsOption := urls)
    in RequestFilter opts'

-- | Optional parameters for RequestFilter.
-- | ### Options:
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


-- | Common to all events
foreign import addListener_ :: forall d ev.
    EffectFn4 ev Foreign (EffectFn1 {|d} Foreign) (Array String) Unit


-- | onBeforeRequest with a blocking callback. Being blocking allows it to
-- | cancel and redirect responses.
-- | [onBeforeRequest](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/webRequest/onBeforeRequest)
foreign import data BeforeRequestBlockingEvent :: Type
-- | Value of this type
foreign import onBeforeRequestBlocking :: BeforeRequestBlockingEvent
instance beforeRequestBlockingEvent
    :: Event BeforeRequestBlockingEvent -- event type
             RequestFilter -- event params
             OnBeforeRequestDetails -- callback argument
             (Options BeforeRequestResponse) -- callback return type
             where
    addListener event (RequestFilter opts) callback =
        let filter = options opts
            validateArgs = OnBeforeRequestDetails
            validateRet = options
            wrappedCallback =
                mkEffectFn1 (map validateRet <<< callback <<< validateArgs)
        in runEffectFn4 addListener_ event filter wrappedCallback ["blocking"]

-- | onBeforeRequest with a non-blocking callback. Being non-blocking allows it
-- | to only see requests, but not react to them
-- | [onBeforeRequest](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/webRequest/onBeforeRequest)
foreign import data BeforeRequestEvent :: Type
-- | Value of this type
foreign import onBeforeRequest :: BeforeRequestEvent
instance beforeRequestEvent
    :: Event BeforeRequestEvent -- event type
             RequestFilter -- event params
             OnBeforeRequestDetails -- callback argument
             Unit -- callback return type
             where
    addListener event (RequestFilter opts) callback =
        let filter = options opts
            validateArgs = OnBeforeRequestDetails
            validateRet = const $ unsafeToForeign {}
            wrappedCallback = mkEffectFn1 (map validateRet <<< callback <<< validateArgs)
        in runEffectFn4 addListener_ event filter wrappedCallback []

-- | Argument of event callback. Wraps the dict because type synonyms aren't
-- | allowed in instance declarations
newtype OnBeforeRequestDetails = OnBeforeRequestDetails OnBeforeRequestDict
-- | Argument to callback of onBeforeRequest events.
-- |
-- | XXX: `documentUrl` may be undefined, use carefully!
-- |
-- | TODO: `type` is stringified ResourceType, we need to parse it back, and
-- | parser function is not exported from this module
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
    , type :: String
    , url :: String
    , urlClassification :: {firstParty :: Array String, thirdParty :: Array String}
    }

-- | Used for return type of event callback. The real return type of callback
-- | is `Options BeforeRequestResponse`, so you construct them using `Options`
-- | syntax. You can find the options below.
data BeforeRequestResponse


-- | onBeforeSendHeaders with a blocking callback. Being blocking allows it to
-- | modify the headers.
-- | [onBeforeSendHeaders](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/webRequest/onBeforeSendHeaders)
foreign import data BeforeSendHeadersBlockingEvent :: Type
-- | Value of event
foreign import onBeforeSendHeadersBlocking :: BeforeSendHeadersBlockingEvent
instance beforeSendHeadersBlockingEvent
    :: Event BeforeSendHeadersBlockingEvent -- event type
             RequestFilter -- event params
             OnBeforeSendHeadersDetails -- callback arguments
             (Options BeforeSendHeadersResponse) -- callback return type
             where
    addListener event (RequestFilter opts) callback =
        let filter = options opts
            validateArgs = OnBeforeSendHeadersDetails
            validateRet = options
            wrappedCallback =
                mkEffectFn1 (map validateRet <<< callback <<< validateArgs)
            extraSpec = ["blocking", "requestHeaders"]
        in runEffectFn4 addListener_ event filter wrappedCallback extraSpec

-- | Argument of event callback. Wraps the dict because type synonyms aren't
-- | allowed in instance declarations
newtype OnBeforeSendHeadersDetails =
    OnBeforeSendHeadersDetails OnBeforeSendHeadersDict
-- | Argument to callback of onBeforeSendHeaders events.
-- |
-- | XXX: `documentUrl` may be undefined, use carefully!
-- |
-- | TODO: `type` is stringified ResourceType, we need to parse it back, and
-- | parser function is not exported from this module
-- | Argument of event callback
type OnBeforeSendHeadersDict =
    { documentUrl :: String
    , frameId :: Int
    , method :: String
    , originUrl :: String
    , parentFrameId :: Int
    -- , proxyInfo :: Big optional type
    , requestHeaders :: Array {name :: String, value :: String}
    , requestId :: String
    , tabId :: Int
    , thirdParty :: Boolean
    , timeStamp :: Number
    , type :: String
    , url :: String
    , urlClassification :: {firstParty :: Array String, thirdParty :: Array String}
    }

-- | Used for return type of event callback. The real return type of callback
-- | is `Options BeforeSendHeadersResponse`, so you construct them using `Options`
-- | syntax. You can find the options below.
data BeforeSendHeadersResponse


-- | Unused event response. TODO: create event for it
data AuthRequiredResponse
-- | Unused event response. TODO: create event for it
data HeadersReceivedResponse

-- | Request handlers can return various types of BlockingResponse, and each
-- | blocking response can have missing options. So we create classes: where
-- | each option is allowed to be present.
-- |
-- | This one is for responses that have `cancel` field
class HasCancel a
instance      cancelBeforeRequest     :: HasCancel BeforeRequestResponse
else instance cancelBeforeSendHeaders :: HasCancel BeforeSendHeadersResponse
else instance cancelHeadersReceived   :: HasCancel HeadersReceivedResponse
else instance cancelAuthRequired      :: HasCancel AuthRequiredResponse

-- | Like `HasCancel`. For responses that have `redirect` field
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
