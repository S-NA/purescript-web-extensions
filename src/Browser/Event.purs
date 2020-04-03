-- | [events](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/events)
-- | The documentation is scarce, working on pieces that work in my example
-- | extension.
module Browser.Event
  ( Event, addListener
  ) where

import Effect (Effect)
import Effect.Uncurried ( EffectFn2, EffectFn1
                        , runEffectFn2, mkEffectFn1
                        )

import Prelude


-- | Object which you can listen on.
foreign import data Event :: Type

-- | Add event listener to an event. The callback receives JSON data which you
-- | have sent, and it's your job to make sure the type is correct at call site.
-- | As of March 2020 there is no docs link for this method.
addListener :: forall m. ({ | m} -> Effect Unit) -> Event -> Effect Unit
addListener = runEffectFn2 addListener_ <<< mkEffectFn1
foreign import addListener_ :: forall m.
  EffectFn2 (EffectFn1 { | m} Unit) Event Unit
