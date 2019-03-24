module Browser.Tabs where

import Prelude

import Data.Options (Option, Options, opt, options)
import Effect (Effect)
import Effect.Uncurried (EffectFn1, runEffectFn1)
import Effect.Promise (Promise)
import Foreign (Foreign)

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
	, id :: Int
	, incognito :: Boolean
	, index :: Int
	, isArticle :: Boolean
	, isInReaderMode :: Boolean
	, lastAccessed :: Number
	, mutedInfo :: String --tabs.MutedInfo
	, openerTabId :: Int
	, pinned :: Boolean
	, selected :: Boolean
	, sessionId :: Int
	, status :: String
	, title :: String
	, url :: String
	, width :: Int
	, windowId :: Int
	}

data ScriptDetails

allFrames :: Option ScriptDetails Boolean
allFrames = opt "allFrames"

code :: Option ScriptDetails String
code = opt "code"

file :: Option ScriptDetails String
file = opt "file"

frameId :: Option ScriptDetails Int
frameId = opt "frameId"

matchAboutBlank :: Option ScriptDetails Boolean
matchAboutBlank = opt "matchAboutBlank"

runAt :: Option ScriptDetails String
runAt = opt "runAt"

foreign import executeScriptImpl :: EffectFn1 Foreign (Promise (Array Foreign))

executeScript :: Options ScriptDetails -> Effect (Promise (Array Foreign))
executeScript = options >>> runEffectFn1 executeScriptImpl

foreign import update :: String -> Effect Unit -> Effect Unit
foreign import logger :: forall a b. a -> b--Effect Unit -> Effect Unit
foreign import test :: Unit
foreign import array :: Array Int
