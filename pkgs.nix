{ system ? builtins.currentSystem, overlays ? [] }:
  let 
    sbt-drv-repo = builtins.fetchTarball {
      url = "https://github.com/zaninime/sbt-derivation/archive/master.tar.gz";
    };
    sbt-drv-overlay = import "${sbt-drv-repo}/overlay.nix";
  in 
    import <nixpkgs> { inherit system; overlays = overlays ++ [ (import ./overlay.nix) sbt-drv-overlay ]; }
