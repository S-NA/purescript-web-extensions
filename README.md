# Purescript Web Extensions

This is a fork from losnappas. I've expanded their API and enhanced
documentation. I've also broke their API in places, so it may be incompatable
as a drop-in replacement.

Well, it's a start. Actually, turns out that it's *yet another start*. https://github.com/bodil/purescript-chrome-api

Well, Chrome and Firefox api's are different (promises vs callbacks).

## Getting documentation

This library is currently not in a package set, so you need to build the docs
yourself. First please see the [Building
instructions](./README.md#Building-for-development) and build the library. Then
you can generate the docs with with purescript compiler:
`npx purs docs --format html src/**/*.purs .spago/**/src/**/*.purs`
Next you can open and browse the docs in your favourite browser:
`firefox ./generated-docs/html/Browser.WebRequest.html`
There will be a lot of unrelated library documentation there, that's purescript
current limitation. Fortunately the modules you are interested in start with
Browser and so are on top.

## Installation

This library is currently not stable or complete enough to be in a package set,
so you need to add it manually. There are two ways to do that:

1. Using a git submodule:
  ```sh
  git submodule add https://gitlab.com/d86leader/purescript-web-extensions.git ./libs/web-extensions
  ```
  Then modify your `packages.dhall` with additions:
  ```dhall
  let additions =
    { web-extensions = ./libs/web-extensions/spago.dhall as Location
    }
  ```
  And add `web-extensions` to your `spago.dhall` as dependencies.

  Also as the library is very much incomplete, you would probably want to fork
  it yourself and add your own repo as a submodule. Don't forget to merge
  request later!

2. Adding as an extra-dep. Modify your packages.dhall with additions:
  ```dhall
    let additions =
      { web-extensions =
          { dependencies =
            [ "aff"
            , "aff-promise"
            , "console"
            , "effect"
            , "foreign"
            , "nullable"
            , "options"
            , "prelude"
            , "promises"
            ]
          , repo =
              "https://gitlab.com/d86leader/purescript-web-extensions.git"
          , version =
              "c764f569d80e7a507d945c9e2647a871e735a8b6"
          }
      }

  ```

## Usage

Read the files and then post issues when you're confused. Because I know there
isn't enough documentation in there.

## Examples

The more recent examples: mozilla example extensions rewritten in purescript:
1. [WebRequest API](https://gist.github.com/d86leader/d4649e41b75e325e8e6ba41e1b628b73)
2. [Runtime and Tabs API](https://github.com/d86leader/purescript-webext-example2)

Older examples:
1. I've used this [here](https://gitlab.com/losnappas/multiple-windows-single-session).

  I didn't use Aff because I didn't know how to intertwine it with the event listeners. I did try, and that's why the Aff folder is here.

## Building for development

Using npm:
- `make` to install dependencies and build the library
- If you prefer to do it by hand, use the commands in the makefile:
  * `npm install` to install PureScript and Spago
  * `npx spago build` to build the library

Using yarn:
- `yarn install` installs the required version of Purescript and Spago.
- `yarn build` builds the library.
- `yarn build:ide` builds the library, but with JSON formatted output as expected by the Atom/VSCode plugins.
