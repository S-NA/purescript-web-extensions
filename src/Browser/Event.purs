-- | [events](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/events)
-- |
-- | The documentation is scarce, working on pieces that work in my example
-- | extension.
module Browser.Event
  ( class Event, addListener
  , SimpleEvent
  , addListenerE, addListenerU, addListenerEU
  ) where

import Effect (Effect)
import Effect.Uncurried (EffectFn2, EffectFn1, runEffectFn2, mkEffectFn1)

import Prelude


-- | Typeclass for events. The API is vast and different in different places,
-- | and it captures that. See SimpleEvent for example implementation.
-- |
-- | Arguments:
-- |    - `event` - the event type
-- |    - `args` - arguments to event creation, like filters and such
-- |    - `cbArgs` - arguments to event callback
-- |    - `cbRet` - return type of event callback. Some events have callbacks
-- |      that block execution until the callback returns a value that says what
-- |      to do next.
class Event event args cbArgs cbRet | event -> args cbArgs cbRet where
  -- | Add listener to event
  addListener :: event -> args -> (cbArgs -> Effect cbRet) -> Effect Unit


-- | Add listner in a common case where listener doesn't receive any arguments.
-- | Mnemonic is E for simple Effect.
-- |
-- | Arguments:
-- |    - `event` - the event object
-- |    - `args` - arguments to event creation, like filters and such
-- |    - `Effect cbRet` - callback, a simple effect
addListenerE :: forall event args cbRet. Event event args Unit cbRet
  => event -> args -> Effect cbRet -> Effect Unit
addListenerE event args cb = addListener event args (const cb)

-- | Add listner in a common case where event doesn't have any arguments.
-- | Mnemonic is U for Unit argument
addListenerU :: forall event cbArgs cbRet. Event event Unit cbArgs cbRet
  => event -> (cbArgs -> Effect cbRet) -> Effect Unit
addListenerU = flip addListener unit

-- | Add listner in a common case where listener doesn't receive any arguments,
-- | and event also doesn't have any arguments
addListenerEU :: forall event cbRet. Event event Unit Unit cbRet
  => event -> Effect cbRet -> Effect Unit
addListenerEU event cb = addListener event unit (const cb)


-- | The most basic event, without any parameters.
foreign import data SimpleEvent :: Type
instance simpleEvent :: Event SimpleEvent Unit Unit Unit where
  addListener ev _ cb = runEffectFn2 simpleAddListener_ ev $ mkEffectFn1 cb

foreign import simpleAddListener_
  :: EffectFn2 SimpleEvent (EffectFn1 Unit Unit) Unit
