module Browser.Aff.Runtime where

import Browser.Event (SimpleEvent)

foreign import onStartup :: SimpleEvent
foreign import onSuspend :: SimpleEvent
