module Browser.Aff.Event where

import Prelude (Unit)
import Effect (Effect)

foreign import data EventListener :: Type
--foreign import data BrowserEvent :: Type

-- | This function itself is effectful as otherwise it would break referential
-- | transparency - `eventListener f /= eventListener f`. This is worth noting
-- | as you can only remove the exact event listener value that was added.
foreign import eventListener
  :: forall a b. (a -> Effect b) -> Effect EventListener
