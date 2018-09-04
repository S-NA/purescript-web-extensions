module Browser.Aff.BrowserAction where

import Prelude (Unit)
import Effect (Effect)
import Browser.Event (EventListener)
--import Browser.Tabs (Tab)

foreign import onClicked :: EventListener -> Effect Unit

