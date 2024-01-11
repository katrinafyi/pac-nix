{ runCommand
, python3
, cacert
, git
, nix
, nix-update
}:

runCommand 
"pac-nix-update" 
{
  buildInputs = [
    python3
    cacert
    git
    nix
    nix-update
  ];

  meta.mainProgram = "pac-nix-update";
} 
''
mkdir -p $out/bin
cp ${./update.py} $out/bin/pac-nix-update
''
