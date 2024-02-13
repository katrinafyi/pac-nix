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
, asli
}:

buildDunePackage {
  pname = "asli";
  version = "unstable-2024-02-09";

  minimalOCamlVersion = "4.09";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp";
    rev = "a2b5cf4002417faef7920bc9b22dda5faccc91d8";
    sha256 = "sha256-N78HtrF+9C6QJlqw9NDE2LbgbENf3wdArHIq4hsm5bo=";
  };

  checkInputs = [ alcotest ];
  buildInputs = [ linenoise ];
  nativeBuildInputs = [ ott menhir ];
  propagatedBuildInputs = [ dune-site z3 pcre pprint zarith ocaml_z3 ocaml_pcre cohttp-lwt-unix ];

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
  };

  meta = {
    homepage = "https://github.com/UQ-PAC/aslp";
    description = "ASL partial evaluator to extract semantics from ARM's MRA.";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
