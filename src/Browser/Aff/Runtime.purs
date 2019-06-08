module Browser.Aff.Runtime where

import Prelude (Unit)
import Effect (Effect)
import Browser.Event (EventListener)

foreign import onStartup :: EventListener -> Effect Unit
foreign import onSuspend :: EventListener -> Effect Unit
