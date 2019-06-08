module Browser.Aff.Storage.Local where

import Prelude (Unit, (>>=))
import Control.Promise (Promise, toAff)
import Foreign (Foreign)
import Effect.Uncurried (EffectFn1, runEffectFn1)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)

--type Keys k =
--	{ obj :: Foreign
--	| k
--	}
--
foreign import _get :: EffectFn1 (Array String) (Promise Foreign)

get :: Array String -> Aff Foreign
get f = liftEffect (runEffectFn1 _get f) >>= toAff

foreign import _set :: EffectFn1 Foreign (Promise Unit)

-- | e.g. 	test <- set $ unsafeToForeign { x: event }
set :: Foreign -> Aff Unit
set f = liftEffect (runEffectFn1 _set f) >>= toAff
