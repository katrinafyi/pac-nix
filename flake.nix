{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.sbt-derivation.url = "github:zaninime/sbt-derivation";
  inputs.sbt-derivation.flake = false;

  outputs = { self, nixpkgs, sbt-derivation, ... }:
    let
      lib = nixpkgs.lib;
      overlay = import ./overlay.nix;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      nixpkgss = lib.genAttrs systems
        (system: (import nixpkgs {
          system = system;
          overlays = [
            self.overlays.default
            (import "${sbt-derivation}/overlay.nix")
          ];
        }));

      forAllSystems = f:
        lib.genAttrs
          systems
          (system: f nixpkgss.${system});

      onlyDerivations = lib.filterAttrs (_: lib.isDerivation);

      makeAll = nixpkgs: pkgs':
        nixpkgs.symlinkJoin {
          name = "pac-nix-all";
          paths = lib.attrValues pkgs';
        };
    in
    {
      packages = forAllSystems (pkgs:
        let pkgs' = onlyDerivations (self.overlays.default pkgs pkgs);
        in pkgs' // { all = makeAll pkgs pkgs'; });

      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);

      overlays.default = import ./overlay.nix;

      nixConfig.substituters = [ "https://pac-nix.cachix.org/" ];
    };
}
