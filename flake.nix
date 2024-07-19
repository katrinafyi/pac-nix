{
  nixConfig.extra-substituters = [ "https://pac-nix.cachix.org/" ];
  nixConfig.extra-trusted-public-keys = [ "pac-nix.cachix.org-1:l29Pc2zYR5yZyfSzk1v17uEZkhEw0gI4cXuOIsxIGpc=" ];

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  # inputs.nixpkgs-upstream.url = "github:nixos/nixpkgs/nixos-unstable";
  # inputs.nixpkgs.url = "github:katrinafyi/nixpkgs/pac-nix";

  outputs = { self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      overlay = import ./overlay.nix;

      systems = [
        "x86_64-linux"
        "aarch64-linux"

        "aarch64-darwin"
        "x86_64-darwin"
      ];

      patches = fetchpatch: [ ];

      nixpkgss = lib.genAttrs systems
        (system:
          import nixpkgs {
            system = system;
            overlays = [ overlay ];
          }
        );

      applySystem = sys: lib.mapAttrs (k: v: v.${sys} or v);

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

      # `restrictOverlays attrs` a given attrset of packages to only those
      # defined in the latest overlay, identified by _overlay attributes
      # package sets.
      restrictOverlays = lib.mapAttrsRecursiveCond
        (as: !(as.type or null == "derivation" || as ? _overlay))
        (ks: v:
          if v ? _overlay
          then restrictOverlays (v._overlay v v)
          else v);
    in
    {
      legacyPackages = forAllSystems
        (pkgs: restrictOverlays (overlay pkgs pkgs));

      packages = forAllSystems'
        ({ legacyPackages, pkgs, ... }:
          let drvs = onlyDerivations legacyPackages;
          in drvs // { all = makeAll pkgs drvs; });

      devShells = forAllSystems (pkgs: {
        ocaml = pkgs.callPackage ./ocaml-shell.nix { };
        update = pkgs.callPackage ./update-shell.nix { };
      });

      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);

      overlays.default = overlay;

      lib.nixpkgs = nixpkgss.${builtins.currentSystem};
    };
}
