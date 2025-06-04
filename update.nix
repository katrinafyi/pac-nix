{ lib
, writers
, nix
, nix-update
}:

let binpath = lib.makeBinPath [ nix nix-update ];
in writers.writePython3Bin "pac-nix-update"
{ flakeIgnore = [ "E" "W" ]; }
  (''import os; os.environ['PATH'] = r"""${binpath}""" + os.pathsep + os.environ['PATH']; del os'' +
  builtins.readFile ./update.py)
