{ lib
, fetchFromGitHub
, buildDunePackage
  # pkgs
, pcre
, antlr4
, jdk
, ott
, z3
  # ocamlPackages
, dune-site
, alcotest
, linenoise
, menhir
, pprint
, zarith
, ocaml_z3
, ocaml_pcre
, cohttp-lwt-unix
, mlbdd
, yojson
, ppx_blob
, asli
, testers
}:

buildDunePackage {
  pname = "asli";
  version = "0.3.0-unstable-2025-02-04";

  minimalOCamlVersion = "4.09";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp";
    rev = "e43aeb2039b4d1b6e058f325417cced0b1814632";
    hash = "sha256-PiQSCFaOVmuBIHK+ds123L8LZAwFJAeHTxA0tkFUDEI=";
  };

  checkInputs = [ alcotest ];
  nativeCheckInputs = [ jdk ];
  buildInputs = [ linenoise ppx_blob ];
  nativeBuildInputs = [ ott menhir ];
  propagatedBuildInputs = [ dune-site z3 pcre pprint zarith ocaml_z3 ocaml_pcre yojson cohttp-lwt-unix mlbdd ];

  preConfigure = ''
    mkdir -p $out/share/asli
    cp -rv prelude.asl mra_tools tests $out/share/asli
  '';

  postInstall = ''
    mv -v $out/bin/asli $out/bin/aslp
  '';

  env = {
    ASLI_OTT = ott.out + "/share/ott";
    ANTLR4_JAR_LOCATION = antlr4.jarLocation;
  };

  doCheck = true;

  outputs = [ "out" "dev" ];

  passthru = {
    prelude = "${asli}/share/asli/prelude.asl";
    mra_tools = "${asli}/share/asli/mra_tools";
    dir = "${asli}/share/asli";

    tests.asli = testers.testVersion {
      package = asli;
      command = "aslp --version";
      version = "ASL";
    };

    tests.aslp-server = testers.testVersion {
      package = asli;
      command = "command -v aslp-server";
      version = "aslp-server";
    };
  };

  meta = {
    homepage = "https://github.com/UQ-PAC/aslp";
    description = "ASL partial evaluator to extract semantics from ARM's MRA.";
    maintainers = with lib.maintainers; [ katrinafyi ];
    mainProgram = "aslp";
  };
}
