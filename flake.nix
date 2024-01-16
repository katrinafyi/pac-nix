{
  nixConfig.extra-substituters = [ "https://pac-nix.cachix.org/" ];
  nixConfig.extra-trusted-public-keys = [ "pac-nix.cachix.org-1:l29Pc2zYR5yZyfSzk1v17uEZkhEw0gI4cXuOIsxIGpc=" ];

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
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
          overlays = [ self.overlays.default ];
        }));

      applySystem = sys: lib.mapAttrs (k: v: if v ? sys then v.${sys} else v);

      forAllSystems' = f:
        lib.genAttrs
          systems
          (sys: f (applySystem sys self // { pkgs = nixpkgss.${sys}; system = sys; }));

      forAllSystems = f: forAllSystems' (x: f x.pkgs);

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

      devShells = forAllSystems (pkgs: {
        ocaml = pkgs.callPackage ./ocaml-shell.nix { };
        update = pkgs.callPackage ./update-shell.nix { };
      });

      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);

      overlays.default = import ./overlay.nix;

      lib.nixpkgs = nixpkgss.${builtins.currentSystem};
    };
}
