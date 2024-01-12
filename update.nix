{ lib
, stdenv
, runCommand
, makeWrapper
, python3
, git
  # , nix
, nix-update
}:

let path = lib.makeBinPath [ git nix-update ];
in stdenv.mkDerivation {
  pname = "pac-nix-update";
  version = "0.1.0";
  buildInputs = [ python3 makeWrapper ];

  src = ./update.py;
  dontUnpack = true;

  meta.mainProgram = "pac-nix-update";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -v $src $out/bin/pac-nix-update
    wrapProgram $out/bin/pac-nix-update \
      --suffix PATH : ${path}

    runHook postInstall
  '';
}
