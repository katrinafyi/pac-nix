{ writers
, nix
, nix-update
}:

writers.writePython3Bin "pac-nix-update"
{ libraries = [ nix nix-update ]; flakeIgnore = [ "E" "W" ]; }
  (builtins.readFile ./update.py)
