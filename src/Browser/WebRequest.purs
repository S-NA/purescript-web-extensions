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

    , CommonDetails (..), HttpHeader (..)

    , BeforeRequestBlockingEvent, onBeforeRequestBlocking
    , BeforeRequestEvent, onBeforeRequest
    , BeforeRequestDetails (..), BeforeRequestDict (..), BeforeRequestResponse

    , BeforeSendHeadersBlockingEvent, onBeforeSendHeadersBlocking
    , BeforeSendHeadersDetails (..), BeforeSendHeadersDict (..)
    , BeforeSendHeadersResponse

    , HeadersReceivedBlockingEvent, onHeadersReceivedBlocking
    , HeadersReceivedDetails (..), HeadersReceivedDict (..), HeadersReceivedResponse

    , AuthRequiredBlockingEvent, onAuthRequiredBlocking
    , AuthRequiredDetails (..), AuthRequiredDict (..), AuthRequiredResponse

    , class HasCancel
    , class HasRedirectUrl
    , authCredentials, cancel, redirectUrl, requestHeaders, responseHeaders
    , upgradeToSecure
    ) where

import Prelude
import Browser.Event (class Event)
import Browser.Tabs (TabId)
import Control.Alternative (class Alternative, empty)
import Data.Functor.Contravariant (cmap)
import Data.Options (Option, Options, opt, options, (:=))
import Data.UndefinedOr (UndefinedOr)
import Effect.Uncurried (EffectFn4, EffectFn1, runEffectFn4, mkEffectFn1)
import Foreign (Foreign, unsafeToForeign)


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


-- | Event callbacks have many common parameters. They are collected here so I
-- | don't repeat myself.
-- |
-- | To get help on fields, consult MDN on corresponding event. The
-- | `addListener` section there contains description of every field.
-- |
-- | TODO: `type` is stringified ResourceType, we need to parse it back, and
-- | parser function is not exported from this module
type CommonDetails =
    ( frameId :: Int
    , method :: String
    , parentFrameId :: Int
    -- , proxyInfo :: Big optional type
    , requestId :: String
    , tabId :: TabId
    , thirdParty :: Boolean
    , timeStamp :: Number
    , type :: String
    , url :: String
    , urlClassification :: {firstParty :: Array String, thirdParty :: Array String}
    )

-- | HTTP headers, present in events where browser sends them or website sends them.
-- |
-- | XXX: there may be a `binaryValue` field instead of value
type HttpHeader = {name :: String, value :: String}

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
             BeforeRequestDetails -- callback argument
             (Options BeforeRequestResponse) -- callback return type
             where
    addListener event (RequestFilter opts) callback =
        let filter = options opts
            validateArgs = BeforeRequestDetails
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
             BeforeRequestDetails -- callback argument
             Unit -- callback return type
             where
    addListener event (RequestFilter opts) callback =
        let filter = options opts
            validateArgs = BeforeRequestDetails
            validateRet = const $ unsafeToForeign {}
            wrappedCallback = mkEffectFn1 (map validateRet <<< callback <<< validateArgs)
        in runEffectFn4 addListener_ event filter wrappedCallback []

-- | Argument of event callback. Wraps the dict because type synonyms aren't
-- | allowed in instance declarations
newtype BeforeRequestDetails = BeforeRequestDetails BeforeRequestDict
-- | Argument to callback of onBeforeRequest events.
type BeforeRequestDict =
    { documentUrl :: UndefinedOr String
    , frameAncestors :: Array {url :: String, frameId :: Int}
    , originUrl :: String
    -- , requestBody :: Big optional type
    | CommonDetails
    }

-- | Used for return type of event callback. The real return type of callback
-- | is `Options BeforeRequestResponse`, so you construct them using `Options`
-- | syntax. You can find the options below, under all events.
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
             BeforeSendHeadersDetails -- callback arguments
             (Options BeforeSendHeadersResponse) -- callback return type
             where
    addListener event (RequestFilter opts) callback =
        let filter = options opts
            validateArgs = BeforeSendHeadersDetails
            validateRet = options
            wrappedCallback =
                mkEffectFn1 (map validateRet <<< callback <<< validateArgs)
            extraSpec = ["blocking", "requestHeaders"]
        in runEffectFn4 addListener_ event filter wrappedCallback extraSpec

-- | Argument of event callback. Wraps the dict because type synonyms aren't
-- | allowed in instance declarations
newtype BeforeSendHeadersDetails =
    BeforeSendHeadersDetails BeforeSendHeadersDict
-- | Argument to callback of onBeforeSendHeaders events
type BeforeSendHeadersDict =
    { documentUrl :: UndefinedOr String
    , originUrl :: String
    , requestHeaders :: Array HttpHeader
    | CommonDetails
    }

-- | Used for return type of event callback. The real return type of callback
-- | is `Options BeforeSendHeadersResponse`, so you construct them using `Options`
-- | syntax. You can find the options below, under all events.
data BeforeSendHeadersResponse


-- | onHeadersReceived with a blocking callback. Being blocking allows it to
-- | cancel and redirect responses, and modify headers.
-- | [onHeadersReceived](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/webRequest/onHeadersReceived)
foreign import data HeadersReceivedBlockingEvent :: Type
-- | Value of this type
foreign import onHeadersReceivedBlocking :: HeadersReceivedBlockingEvent
instance headersReceivedBlockingEvent
    :: Event HeadersReceivedBlockingEvent -- event type
             RequestFilter -- request params
             HeadersReceivedDetails -- callback arguments
             (Options HeadersReceivedResponse) -- callback return type
             where
    addListener event (RequestFilter opts) callback =
        let filter = options opts
            validateArgs = HeadersReceivedDetails
            validateRet = options
            wrappedCallback =
                mkEffectFn1 (map validateRet <<< callback <<< validateArgs)
            extraInfo = ["blocking", "responseHeaders"]
        in runEffectFn4 addListener_ event filter wrappedCallback extraInfo

-- | Argument of event callback. Wraps the dict because type synonyms aren't
-- | allowed in instance declarations
newtype HeadersReceivedDetails = HeadersReceivedDetails HeadersReceivedDict
-- | Argument to callback of onHeadersReceivedBlocking event.
type HeadersReceivedDict =
    { documentUrl :: UndefinedOr String
    , responseHeaders :: Array HttpHeader
    , statusCode :: Int
    , statusLine :: String
    | CommonDetails
    }

-- | Used for return type of event callback. The real return type of callback
-- | is `Options BeforeRequestResponse`, so you construct them using `Options`
-- | syntax. You can find the options below, under all events.
data HeadersReceivedResponse


-- | Fired when the server sends a 401 or 407 status code (that is, when the
-- | server is asking the client to provide authentication credentials, such as
-- | a username and password). This is a blocking event, and you can respond by
-- | cancelling request or providing credentials.
-- | [onAuthRequired](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/webRequest/onAuthRequired)
foreign import data AuthRequiredBlockingEvent :: Type
-- | Value of event
foreign import onAuthRequiredBlocking :: AuthRequiredBlockingEvent
instance authRequiredBlockingEvent
    :: Event AuthRequiredBlockingEvent -- event type
             RequestFilter -- event params
             AuthRequiredDetails -- callback arguments
             (Options AuthRequiredResponse) -- callback return type
             where
    addListener event (RequestFilter opts) callback =
        let filter = options opts
            validateArgs = AuthRequiredDetails
            validateRet = options
            wrappedCallback =
                mkEffectFn1 (map validateRet <<< callback <<< validateArgs)
            extraSpec = ["blocking", "responseHeaders"]
        in runEffectFn4 addListener_ event filter wrappedCallback extraSpec

-- | Argument of event callback. Wraps the dict because type synonyms aren't
-- | allowed in instance declarations
newtype AuthRequiredDetails = AuthRequiredDetails AuthRequiredDict
-- | Argument to callback of onAuthRequired events. Currently the call of
-- | onAuthRequired for proxies is not implemented here, so isProxy is a dud
-- | and always false
type AuthRequiredDict =
    { challenger :: {host :: String, port :: Int}
    , isProxy :: Boolean
    , realm :: UndefinedOr String
    , responseHeaders :: Array HttpHeader
    , scheme :: String
    , statusCode :: Int
    , statusLine :: String
    | CommonDetails
    }

-- | Used for return type of event callback. The real return type of callback
-- | is `Options AuthRequiredResponse`, so you construct them using `Options`
-- | syntax. You can find the options below, under all events.
data AuthRequiredResponse

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

requestHeaders :: Option BeforeSendHeadersResponse (Array HttpHeader)
requestHeaders = opt "requestHeaders"

responseHeaders :: Option HeadersReceivedResponse (Array HttpHeader)
responseHeaders = opt "responseHeaders"

upgradeToSecure :: Option BeforeRequestResponse Boolean
upgradeToSecure = opt "upgradeToSecure"
