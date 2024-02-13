{ fetchFromGitHub
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
  version = "unstable-2024-02-13";

  minimalOCamlVersion = "4.09";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp";
    rev = "dfa9d8fb29eefdeee5b3e643f852dec00c4606c2";
    sha256 = "sha256-p0Zwn6E1TQDLi/DR869jYklFY9Xvy6mPJ7yHvPYZsaU=";
  };

  checkInputs = [ alcotest ];
  buildInputs = [ linenoise ];
  nativeBuildInputs = [ ott menhir ];
  propagatedBuildInputs = [ dune-site z3 pcre pprint zarith ocaml_z3 ocaml_pcre yojson cohttp-lwt-unix ];

  configurePhase = ''
    export ASLI_OTT=${ott.out + "/share/ott"}
    mkdir -p $out/share/asli
    cp -rv prelude.asl mra_tools tests $out/share/asli
  '';

  shellHook = ''
    export ASLI_OTT=${ott.out + "/share/ott"}
  '';

  outputs = [ "out" "dev" ];

  passthru = {
    prelude = "${asli}/share/asli/prelude.asl";
    mra_tools = "${asli}/share/asli/mra_tools";
    dir = "${asli}/share/asli";

    tests.asli = testers.testVersion {
      package = asli;
      command = "asli --version";
      version = "ASL";
    };
  };

  meta = {
    homepage = "https://github.com/UQ-PAC/aslp";
    description = "ASL partial evaluator to extract semantics from ARM's MRA.";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
