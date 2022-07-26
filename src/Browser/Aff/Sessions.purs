module Browser.Aff.Sessions where

import Prelude (Unit, void, ($), (>>=))
import Effect (Effect)
import Browser.Event (SimpleEvent)
import Browser.Windows (Window)
import Browser.Tabs (Tab)
import Control.Promise (Promise, toAff)
import Foreign (Foreign)
import Data.Options (Option, Options, opt, options)
import Effect.Uncurried (EffectFn1, EffectFn2, EffectFn3, runEffectFn1, runEffectFn2, runEffectFn3)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)


data Filter

maxResults :: Option Filter Int
maxResults = opt "maxResults"

type Session =
  { lastModified :: Number
  , tab :: Tab -- Maybe Tab
  , window :: Window -- Maybe Window
  }

foreign import onChanged :: SimpleEvent

--type SessionId = String -- too much work 4 now.
foreign import restoreImpl :: EffectFn1 String (Promise Session)

restore :: String -> Aff Session
restore s = liftEffect (runEffectFn1 restoreImpl s) >>= toAff

restore_ :: String -> Aff Unit
restore_ str = void $ liftEffect (runEffectFn1 restoreImpl str) >>= toAff

foreign import getRecentlyClosedImpl :: EffectFn1 Foreign (Promise (Array Session))

getRecentlyClosed :: Options Filter -> Aff (Array Session)
getRecentlyClosed opts = liftEffect (getRecentlyClosed' (options opts)) >>= toAff
  where
  getRecentlyClosed' :: Foreign -> Effect (Promise (Array Session))
  getRecentlyClosed' = runEffectFn1 getRecentlyClosedImpl

foreign import setWindowValueImpl :: EffectFn3 Int String String (Promise Unit)
foreign import getWindowValueImpl :: EffectFn2 Int String (Promise String)

-- should be: int -> string -> either string object -> effect promise unit
setWindowValue :: Int -> String -> String -> Aff Unit
setWindowValue i s1 s2 = liftEffect (runEffectFn3 setWindowValueImpl i s1 s2) >>= toAff

getWindowValue :: Int -> String -> Aff String
getWindowValue i s = liftEffect (runEffectFn2 getWindowValueImpl i s) >>= toAff
