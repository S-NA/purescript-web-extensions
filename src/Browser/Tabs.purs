module Browser.Tabs
  ( TabId, Tab (..)
  , ScriptDetails, allFrames, code, file, frameId, matchAboutBlank, runAt
  , executeScript, executeScriptCurrent
  , TabUpdateDetails, active, autoDiscardable, highlighted, loadReplace, muted
  , openerTabId, pinned, selected, successorTabId, url
  , updateCurrent, update
  ) where

import Prelude

import Data.Function.Uncurried (Fn1, Fn2, runFn1, runFn2)
import Data.Options (Option, Options, opt, options)
import Effect.Promise (Promise)

import Foreign (Foreign)


newtype TabId = TabId Int

type Tab =
  { active :: Boolean
  , audible :: Boolean
  , autoDiscardable :: Boolean
  , cookieStoreId :: String
  , discarded :: Boolean
  , favIconUrl :: String
  , height :: Int
  , hidden :: Boolean
  , highlighted :: Boolean
  , id :: TabId
  , incognito :: Boolean
  , index :: Int
  , isArticle :: Boolean
  , isInReaderMode :: Boolean
  , lastAccessed :: Number
  , mutedInfo :: String
  , openerTabId :: TabId
  , pinned :: Boolean
  , selected :: Boolean
  , sessionId :: String
  , status :: String
  , title :: String
  , url :: String
  , width :: Int
  , windowId :: Int
  }


data ScriptDetails
allFrames       :: Option ScriptDetails Boolean
allFrames       = opt "allFrames"
code            :: Option ScriptDetails String
code            = opt "code"
file            :: Option ScriptDetails String
file            = opt "file"
frameId         :: Option ScriptDetails Int
frameId         = opt "frameId"
matchAboutBlank :: Option ScriptDetails Boolean
matchAboutBlank = opt "matchAboutBlank"
runAt           :: Option ScriptDetails String
runAt           = opt "runAt"

foreign import executeScriptImpl :: Fn2 Int Foreign (Promise (Array Foreign))
foreign import executeScriptCurrentImpl :: Fn1 Foreign (Promise (Array Foreign))

executeScript :: TabId -> Options ScriptDetails -> Promise (Array Foreign)
executeScript (TabId id) = options >>> runFn2 executeScriptImpl id
executeScriptCurrent :: Options ScriptDetails -> Promise (Array Foreign)
executeScriptCurrent = options >>> runFn1 executeScriptCurrentImpl


data TabUpdateDetails
active          :: Option TabUpdateDetails Boolean
active          = opt "active"
autoDiscardable :: Option TabUpdateDetails Boolean
autoDiscardable = opt "autoDiscardable"
highlighted     :: Option TabUpdateDetails Boolean
highlighted     = opt "highlighted"
loadReplace     :: Option TabUpdateDetails Boolean
loadReplace     = opt "loadReplace"
muted           :: Option TabUpdateDetails Boolean
muted           = opt "muted"
openerTabId     :: Option TabUpdateDetails TabId
openerTabId     = opt "openerTabId"
pinned          :: Option TabUpdateDetails Boolean
pinned          = opt "pinned"
selected        :: Option TabUpdateDetails Boolean
selected        = opt "selected"
successorTabId  :: Option TabUpdateDetails TabId
successorTabId  = opt "successorTabId"
url             :: Option TabUpdateDetails String
url             = opt "url"

foreign import updateCurrentImpl :: Fn1 Foreign (Promise Tab)
foreign import updateImpl :: Fn2 Int Foreign (Promise Tab)

updateCurrent :: Options TabUpdateDetails -> Promise Tab
updateCurrent = options >>> runFn1 updateCurrentImpl
update :: TabId -> Options TabUpdateDetails -> Promise Tab
update (TabId id) = options >>> runFn2 updateImpl id
