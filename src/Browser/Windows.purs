module Browser.Windows where

import Prelude (Unit)
import Browser.Event (SimpleEvent)
import Effect.Promise (class Deferred, Promise)
import Foreign (Foreign)
import Data.Options (Option, Options, opt, options)
import Browser.Tabs (Tab)
import Data.Function.Uncurried (Fn0, Fn1, mkFn0, runFn1)

data GetInfo

populate :: Option GetInfo Boolean
populate = opt "populate"

windowTypes :: Option GetInfo (Array String)
windowTypes = opt "windowTypes"

data CreateData

allowScriptsToClose :: Option CreateData Boolean
allowScriptsToClose = opt "allowScriptsToClose"

focused :: Option CreateData Boolean
focused = opt "focused"

height :: Option CreateData Int
height = opt "height"

incognito :: Option CreateData Boolean
incognito = opt "incognito"

left :: Option CreateData Int
left = opt "left"

state :: Option CreateData String
state = opt "state"

tabId :: Option CreateData Int
tabId = opt "tabId"

titlePreface :: Option CreateData String
titlePreface = opt "titlePreface"

top :: Option CreateData Int
top = opt "top"

type' :: Option CreateData String
type' = opt "type"

-- String OR Array String , canonically.
url :: Option CreateData (Array String)
url = opt "url"

width :: Option CreateData Int
width = opt "width"

-- should this be data instead of type? wtf
type Window =
  { alwaysOnTop :: Boolean
  , focused :: Boolean
  , height :: Int
  , id :: Int
  , incognito :: Boolean
  , left :: Int
  , sessionId :: String
  , state :: String
  , tabs :: Array Tab
  , title :: String
  , top :: Int
  , type :: String
  , width :: Int
  }

foreign import onRemoved :: SimpleEvent
foreign import getAllImpl :: Unit -> Promise (Array Window)
foreign import getAllImpl1 :: Fn1 Foreign (Promise (Array Window))
foreign import createImpl :: Fn1 Foreign (Promise Window)
foreign import removeImpl :: Fn1 Int (Promise Unit)


-- | Get info on all windows.
getAll :: Fn0 (Promise (Array Window))
getAll = mkFn0 getAllImpl

getAll1 :: Deferred => Options GetInfo -> Promise (Array Window)
getAll1 opts = getAll1' (options opts)
  where
  getAll1' :: Deferred => Foreign -> Promise (Array Window)
  getAll1' = runFn1 getAllImpl1

-- | Create a window.
create :: Deferred => Options CreateData -> Promise Window
create opts = create' (options opts)
  where
  create' :: Deferred => Foreign -> Promise Window
  create' = runFn1 createImpl

remove :: Deferred => Int -> Promise Unit
remove = runFn1 removeImpl
