{ pkgs ? import ./pkgs.nix { } }:
pkgs.mkShell {
  name = "update-py-shell";
  packages = with pkgs; [
    python3
    cacert
    git
    nix
    nix-update
  ];

  meta = {
    description = "Shell for update.py";
  };
}
