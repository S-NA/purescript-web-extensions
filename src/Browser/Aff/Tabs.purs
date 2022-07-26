module Browser.Aff.Tabs where
-- useless module.


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

foreign import logger :: forall a b. a -> b--Effect Unit -> Effect Unit
