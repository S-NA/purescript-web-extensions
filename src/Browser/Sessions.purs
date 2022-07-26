module Browser.Sessions where

import Prelude (Unit)
import Browser.Event (SimpleEvent)
import Browser.Windows (Window)
import Browser.Tabs (Tab)
import Effect.Promise (class Deferred, Promise)
import Foreign (Foreign)
import Data.Options (Option, Options, opt, options)
import Data.Function.Uncurried (Fn1, Fn2, Fn3, runFn1, runFn2, runFn3)

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
foreign import restoreImpl :: Fn1 String (Promise Session)

restore :: Deferred => String -> Promise Session
restore = runFn1 restoreImpl

foreign import getRecentlyClosedImpl :: Fn1 Foreign (Promise (Array Session))

getRecentlyClosed :: Deferred => Options Filter -> Promise (Array Session)
getRecentlyClosed opts = getRecentlyClosed' (options opts)
  where
  getRecentlyClosed' :: Deferred => Foreign -> Promise (Array Session)
  getRecentlyClosed' = runFn1 getRecentlyClosedImpl

foreign import setWindowValueImpl :: Fn3 Int String String (Promise Unit)
foreign import getWindowValueImpl :: Fn2 Int String (Promise String)

-- should be: int -> string -> either string object -> effect promise unit
setWindowValue :: Deferred => Int -> String -> String -> Promise Unit
setWindowValue = runFn3 setWindowValueImpl

getWindowValue :: Deferred => Int -> String -> Promise String
getWindowValue = runFn2 getWindowValueImpl
