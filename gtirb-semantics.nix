{ lib,
  fetchFromGitHub,
  ocaml,
  pkgs,
  ocamlPackages,
  protobuf,
  asli,
  ocaml-hexstring
}:

ocamlPackages.buildDunePackage rec {
  pname = "gtirb_semantics";
  version = "unstable-2024-01-03";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "gtirb-semantics";
    rev = "ee087c10d532867ec160900a8bc688237e22c9b5";
    sha256 = "sha256-YruvoMo/PJJcETlDBJQukY040RPy1o3XLgerWiO3Zeo=";
  };

  checkInputs = [ ];
  buildInputs = [ asli ocaml-hexstring ocamlPackages.ocaml-protoc-plugin ];
  nativeBuildInputs = [ protobuf ocamlPackages.ocaml-protoc-plugin ];
  propagatedBuildInputs = (with ocamlPackages; [ base64 ]);
  doCheck = lib.versionAtLeast ocaml.version "4.09";

  configurePhase = ''
    runHook preConfigure
    # ocaml_protoc=${ocamlPackages.ocaml-protoc-plugin.out}/bin/protoc-gen-ocaml
    # substituteInPlace 
    runHook postConfigure
  '';

  meta = {
    homepage = "https://github.com/UQ-PAC/gtirb-semantics";
    description = "Add instruction semantics to the IR of a dissassembled ARM64 binary";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
