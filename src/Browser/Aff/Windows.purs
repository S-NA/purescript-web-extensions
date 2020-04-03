module Browser.Aff.Windows where

import Prelude (Unit, (>>=))
import Effect (Effect)
import Effect.Class (liftEffect)
import Browser.Event (Event)
import Control.Promise (Promise, toAff)
import Foreign (Foreign)
import Data.Options (Option, Options, opt, options)
import Effect.Uncurried (EffectFn1, runEffectFn1)
import Browser.Tabs (Tab)
import Effect.Aff (Aff)

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


foreign import onRemoved :: Event
foreign import getAllImpl :: Unit -> Effect (Promise (Array Window))
foreign import getAllImpl1 :: EffectFn1 Foreign (Promise (Array Window))
foreign import createImpl :: EffectFn1 Foreign (Promise Window)
foreign import removeImpl :: EffectFn1 Int (Promise Unit)


-- | Get info on all windows.
--getAll :: Fn0 (Aff (Array Window))
--getAll = mkFn0 $ liftEffect (getAllImpl) >>= toAff

getAll1 :: Options GetInfo -> Aff (Array Window)
getAll1 opts = liftEffect (getAll1' (options opts)) >>= toAff
  where
  getAll1' :: Foreign -> Effect (Promise (Array Window))
  getAll1' = runEffectFn1 getAllImpl1

-- | Create a window.
create :: Options CreateData -> Aff Window
create opts = liftEffect (create' (options opts)) >>= toAff
  where
  create' :: Foreign -> Effect (Promise Window)
  create' = runEffectFn1 createImpl

remove :: Int -> Aff Unit
remove r = liftEffect (runEffectFn1 removeImpl r) >>= toAff
