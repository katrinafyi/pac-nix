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
  version = "0.3.0-unstable-2025-02-07";

  minimalOCamlVersion = "4.09";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp";
    rev = "7d03b87bd965ddfea4c7a59d6d8d84c736f17aa1";
    hash = "sha256-4tW9MTlUX42J/1bLgivTKTHq/efXV6pyqCizLmnGOTw=";
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
    ln -v $out/bin/asli $out/bin/aslp
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
  };

  meta = {
    homepage = "https://github.com/UQ-PAC/aslp";
    description = "ASL partial evaluator to extract semantics from ARM's MRA.";
    maintainers = with lib.maintainers; [ katrinafyi ];
    mainProgram = "aslp";
  };
}
