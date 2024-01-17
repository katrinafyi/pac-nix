{ fetchFromGitHub
, buildDunePackage
  # pkgs
, pcre
, ott
, z3
  # ocamlPackages
, alcotest
, linenoise
, menhir
, pprint
, zarith
, ocaml_z3
, ocaml_pcre
, asli
}:

buildDunePackage {
  pname = "asli";
  version = "unstable-2024-01-16";

  minimalOCamlVersion = "4.09";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp";
    rev = "fc60f76057a35538b7e43c6e128a1b0983b868b8";
    sha256 = "sha256-kQYcprdk+t26eMN6xxIFdWlnNfzvJV9CyMVjv00DYGM=";
  };

  checkInputs = [ alcotest ];
  buildInputs = [ linenoise ];
  nativeBuildInputs = [ ott menhir ];
  propagatedBuildInputs = [ z3 pcre pprint zarith ocaml_z3 ocaml_pcre ];

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
