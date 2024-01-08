{ system ? builtins.currentSystem, overlays ? [ ] }:
import <nixpkgs> { inherit system; overlays = overlays ++ [ (import ./overlay.nix) ]; }
