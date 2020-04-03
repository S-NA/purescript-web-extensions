module Browser.Runtime
  ( onStartup, onSuspend, onMessage
  , getUrl
  ) where

import Browser.Event (Event)

-- | Event that fires when you manually send a message between your scripts.
-- | [runtime.onMessage](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/runtime/onMessage)
foreign import onMessage :: Event
-- | Event that fires when the extension installed first starts up.
-- | [runtime.onStartup](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/runtime/onStartup)
foreign import onStartup :: Event
-- | Event that fires just before the extension is unloaded.
-- | [runtime.onSuspend](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/runtime/onSuspend)
foreign import onSuspend :: Event


-- | Get resolved url to extension resource.
-- | [runtime.getURL](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/runtime/getURL)
foreign import getUrl :: String -> String
