{
  outputs = { nixpkgs, ... }:
    import ./default.nix { inherit nixpkgs; };
}

