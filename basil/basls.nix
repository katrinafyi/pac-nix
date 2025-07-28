{ lib
, buildDunePackage
, fetchFromGitHub
, testVersion
, basil_ast
, basls
, menhir
, linol
, linol-lwt
, lsp
, containers
, zarith
, ocamlgraph
, hashcons
, ppx_deriving
, ppxlib
}:

pname:

buildDunePackage {
  pname = pname;
  version = "0.1.0-unstable-2025-07-11";

  src = fetchFromGitHub {
    owner = "ailrst";
    repo = "basls";
    rev = "04d27999b1beec5bce8ada08e12ffa1625ed176e";
    hash = "sha256-TRWfjcPDAR9PQKFJQ+mqAszwuQ7YcVr2AVzaseMjatE=";
  };

  buildInputs =
    [ linol linol-lwt lsp containers zarith hashcons ppx_deriving ppxlib ocamlgraph ]
    ++ lib.optional (pname == "basil_lsp") basil_ast;
  nativeBuildInputs = [ menhir ];

  postPatch = ''
    substituteInPlace lib/lsp/dune \
      --replace-fail ' common' 'basil_ast.common'
    substituteInPlace bin/lsp/dune \
      --replace-fail ' basillang' 'basil_ast'
  '';

  outputs = [ "out" "dev" ];

  meta = {
    homepage = "https://github.com/ailrst/basls";
    description = "A simple proof of concept language server for Basil IR supporting goto definition and the symbol list for
block and procedure labels";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
