{ lib,
  fetchFromGitHub,
  ocaml,
  pkgs,
  ocamlPackages
}:


ocamlPackages.buildDunePackage rec {
  pname = "asli";
  version = "unstable-2023-09-12";

  minimalOCamlVersion = "4.09";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp";
    rev = "f7fd0e8f089b4d9f99d900ca80412eacbc0d1a8f";
    sha256 = "sha256-iHsSHDqvAQjFH0Gw2WbR0cw/lfzVyrzOhFoqNaaYYn8=";
  };

  checkInputs = [ ocamlPackages.alcotest ];
  buildInputs = [ pkgs.z3 ];
  nativeBuildInputs = (with pkgs; [ ott ]) ++ (with ocamlPackages; [ menhir ]);
  propagatedBuildInputs = [ pkgs.pcre ] ++ (with ocamlPackages; [ linenoise pprint zarith z3 ocaml_pcre ]);
  doCheck = lib.versionAtLeast ocaml.version "4.09";

  configurePhase = ''
    export ASLI_OTT=${pkgs.ott.out + "/share/ott"}
    mkdir -p $out/share/asli
    cp -rv prelude.asl mra_tools tests $out/share/asli
  '';

  outputs = [ "out" ];

  meta = {
    homepage = "https://github.com/UQ-PAC/aslp";
    description = "ASL partial evaluator to extract semantics from ARM's MRA.";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
