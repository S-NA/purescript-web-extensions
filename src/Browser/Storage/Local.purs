module Browser.Storage.Local where
-- holy *** the storage api is a MESS. only doing ["key1","key2"] style gets.
import Prelude (Unit)
import Data.Function.Uncurried (Fn1, runFn1)
import Effect.Promise (class Deferred, Promise)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toNullable)

foreign import _get :: forall a b. Fn1 (Nullable b) (Promise a)

get :: forall a b. Deferred => Maybe b -> Promise a
get keys = runFn1 _get (toNullable keys)

foreign import _set :: forall a. Fn1 a (Promise Unit)
-- | e.g. 	test <- set $ unsafeToForeign { x: event }
set :: forall a. Deferred => a -> Promise Unit
set = runFn1 _set

foreign import _clear :: Fn1 Unit (Promise Unit)
-- | Usage: `clear unit`. It's a 0 argument function; hard to map into purescript.
clear :: Deferred => Unit -> Promise Unit
clear = runFn1 _clear
--clear :: Promise Unit
--clear = runFn0 _clear
