{ lib
, writers
, nix
, nix-update
}:

let binpath = lib.makeBinPath [ nix nix-update ];
in writers.writePython3Bin "pac-nix-update"
{ flakeIgnore = [ "E" "W" ]; }
  (''import os; os.environ['PATH'] += os.pathsep + r"""${binpath}"""; del os'' +
  builtins.readFile ./update.py)
