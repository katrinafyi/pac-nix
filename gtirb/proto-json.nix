{ lib
, stdenv
, writers
, python3Packages
, gtirb-semantics
}:

let
  script = writers.writePython3Bin
    "proto-json-script"
    { libraries = [ python3Packages.protobuf ]; flakeIgnore = [ "W" "E" ]; }
    (builtins.readFile "${gtirb-semantics.src}/scripts/proto-json.py");
in
stdenv.mkDerivation {
  pname = "proto-json";
  version = gtirb-semantics.version;

  src = script;

  installPhase = ''
    runHook preInstall
    mkdir $out
    ln -sv $src/* $out/.
    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/UQ-PAC/gtirb-semantics/blob/main/scripts/proto-json.py";
    description = "protobuf <-> json converter";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}

