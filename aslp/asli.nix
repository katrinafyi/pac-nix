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
  version = "unstable-2024-02-14";

  minimalOCamlVersion = "4.09";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp";
    rev = "147b156a29c64f625ad94592d4970659c46cea73";
    sha256 = "sha256-YzfzKcy7A94HP4X3+t9XGJqeFI17eL/HC6WNGkLmY2s=";
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
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
