{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      overlay = import ./overlay.nix;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      nixpkgss = nixpkgs.lib.genAttrs systems
        (system: (import nixpkgs {
          system = system;
          overlays = [ self.overlays.default ];
        }));

      forAllSystems = f:
        nixpkgs.lib.genAttrs
          systems
          (system: f nixpkgss.${system});

      makeAll = nixpkgs: pkgs':
        let lib = nixpkgs.lib;
        in nixpkgs.symlinkJoin {
          name = "pac-nix-all";
          paths = lib.filter lib.isDerivation (lib.attrValues pkgs');
        };
    in
    {
      packages = forAllSystems (pkgs:
        let pkgs' = self.overlays.default pkgs pkgs;
        in pkgs' // { all = makeAll pkgs pkgs'; });

      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);

      overlays.default = import ./overlay.nix;

      nixConfig.substituters = [ "https://pac-nix.cachix.org/" ];
    };
}
