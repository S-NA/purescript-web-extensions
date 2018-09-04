module Browser.Runtime where

import Prelude (Unit)
import Effect (Effect)
import Browser.Event (EventListener)
--import Browser.Tabs (Tab)

foreign import onStartup :: EventListener -> Effect Unit
foreign import onSuspend :: EventListener -> Effect Unit

