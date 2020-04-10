{ sources =
    [ "src/**/*.purs" ]
, name =
    "purescript-web-extensions"
, dependencies =
    [ "aff"
    , "aff-promise"
    , "console"
    , "effect"
    , "foreign"
    , "nullable"
    , "options"
    , "prelude"
    , "promises"
    , "undefined-or"
    ]
, packages =
    ./packages.dhall
}
