{ lib,
  fetchFromGitHub,
  ocaml,
  pkgs,
  ocamlPackages
}:


ocamlPackages.buildDunePackage rec {
  pname = "asli";
  version = "unstable-2023-09-11";

  minimalOCamlVersion = "4.09";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp";
    rev = "partial_eval";
    sha256 = "sha256-oWBumTlfWHf6fwX5jfzzc+3uR9oMFX5BrnQuIc23Leg=";
  };

  checkInputs = [ ocamlPackages.alcotest ];
  buildInputs = [ pkgs.z3 ];
  nativeBuildInputs = (with pkgs; [ ott ]) ++ (with ocamlPackages; [ menhir ]);
  propagatedBuildInputs = with ocamlPackages; [ linenoise pprint zarith z3 ocaml_pcre ];
  doCheck = lib.versionAtLeast ocaml.version "4.09";

  configurePhase = ''
    export ASLI_OTT=${pkgs.ott.out + "/share/ott"}
    mkdir -p $out/asl
    cp -rv prelude.asl mra_tools tests $out/asl
  '';

  outputs = [ "out" ];

  meta = {
    homepage = "https://github.com/UQ-PAC/aslp";
    description = "ASL partial evaluator to extract semantics from ARM's MRA.";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
