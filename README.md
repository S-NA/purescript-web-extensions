# Purescript Web Extensions

Well, it's a start. Actually, turns out that it's *yet another start*. https://github.com/bodil/purescript-chrome-api

Well, Chrome and Firefox api's are different (promises vs callbacks).

## Installation

The easiest way to use this library, since it is not currently in a package set, is to use [Spago](https://github.com/spacchetti/spago). Add `web-extensions` and also `promises` (also not in a package set) into your `packages.dhall` as additional libraries. You will need to know what libraries they depend on: you can find out by looking in the `bower.json` from [purescript-promises](https://github.com/Thimoteus/purescript-promises) and `spago.dhall` from this project.

## Usage

Read the files and then post issues when you're confused. Because I know there isn't enough documentation in there.

## Examples

I've used this [here](https://gitlab.com/losnappas/multiple-windows-single-session).

I didn't use Aff because I didn't know how to intertwine it with the event listeners. I did try, and that's why the Aff folder is here.

## Building for development

- `yarn install` installs the required version of Purescript and Spago.
- `yarn build` builds the library.
- `yarn build:ide` builds the library, but with JSON formatted output as expected by the Atom/VSCode plugins.
