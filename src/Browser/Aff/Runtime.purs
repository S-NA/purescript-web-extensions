module Browser.Aff.Runtime where

import Browser.Event (Event)

foreign import onStartup :: Event
foreign import onSuspend :: Event
