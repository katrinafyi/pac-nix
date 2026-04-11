{
  nixConfig.extra-substituters = [ "https://pac-nix.cachix.org/" ];
  nixConfig.extra-trusted-public-keys = [ "pac-nix.cachix.org-1:l29Pc2zYR5yZyfSzk1v17uEZkhEw0gI4cXuOIsxIGpc=" ];

  # inputs.nixpkgs.url = "github:nixos/nixpkgs/063f43f2dbdef86376cc29ad646c45c46e93234c";

  outputs = { self, nixpkgs }: import ./default.nix { };
}

