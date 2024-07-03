{ lib
, fetchFromGitHub
, buildDunePackage
, ocaml_oasis
, ocamlbuild
, ppx_bap
, ppx_sexp_value
, core_kernel
, findlib
}:

buildDunePackage {
  pname = "bap-build";
  version = "unstable-2024-04-25";

  minimalOCamlVersion = "4.09";

  src = fetchFromGitHub {
    owner = "BinaryAnalysisPlatform";
    repo = "bap";
    rev = "95e81738c440fbc928a627e4b5ab3cccfded66e2";
    hash = "sha256-gogcwqK7EK4Fs4HiCXKxWeFpJ1vJlJupMtJu+8M9kjs=";
  };

  dontConfigure = true;

  patches = [ ./0001-bap_build-filter-empty-library-files.patch ];

  postPatch = ''
    # bap-build does not actually make use of ppx_bap
    substituteInPlace tools/dune --replace-warn '(preprocess (pps ppx_bap))' ""
  '';

  buildInputs = [ ocamlbuild findlib core_kernel ];
  nativeBuildInputs = [ ocaml_oasis ];
  propagatedBuildInputs = [];

  meta = {
    homepage = "https://github.com/BinaryAnalysisPlatform/bap/blob/master/tools/bapbuild.ml";
    description = "bapbuild executable for plugin building";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
