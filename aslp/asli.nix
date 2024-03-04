{ lib
, fetchFromGitHub
, buildDunePackage
  # pkgs
, pcre
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
, yojson
, asli
, testers
}:

buildDunePackage {
  pname = "asli";
  version = "unstable-2024-03-04";

  minimalOCamlVersion = "4.09";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp";
    rev = "b2ead9683bd9f3496a7503eca86cf357e1da3e2e";
    sha256 = "sha256-q/pjEJ+O/J85ejPNB2WYpfjNwzNg6ZrpU1Ks8zpgu0Q=";
  };

  checkInputs = [ alcotest ];
  buildInputs = [ linenoise ];
  nativeBuildInputs = [ ott menhir ];
  propagatedBuildInputs = [ dune-site z3 pcre pprint zarith ocaml_z3 ocaml_pcre yojson cohttp-lwt-unix ];

  preConfigure = ''
    export ASLI_OTT=${ott.out + "/share/ott"}
    mkdir -p $out/share/asli
    cp -rv prelude.asl mra_tools tests $out/share/asli
  '';

  postInstall = ''
    mv -v $out/bin/asli $out/bin/aslp
  '';

  shellHook = ''
    export ASLI_OTT=${ott.out + "/share/ott"}
  '';

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
  };
}
