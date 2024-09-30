{ system ? builtins.currentSystem, overlays ? [ ] }:
let
  lockfile = builtins.fromJSON (builtins.readFile ./flake.lock);
  locked = lockfile.nodes.nixpkgs.locked;
  url =
    if locked.type == "github"
    then with locked; "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz"
    else builtins.throw "pac-nix: non-flake usage requires a locked GitHub repo as nixpkgs (got: ${builtins.toJSON locked})";
  nixpkgs = builtins.fetchTarball url;
in import nixpkgs { inherit system; overlays = overlays ++ [ (import ./overlay.nix) ]; }
