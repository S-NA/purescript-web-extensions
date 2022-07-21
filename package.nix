{ ps-pkgs, ... }:
  with ps-pkgs;
  { version = "0.0.1";
    dependencies = [ aff
                     aff-promise
                     console
                     effect
                     foreign
                     nullable
                     options
                     prelude
                     promises
                     undefined-or
                   ];
  }