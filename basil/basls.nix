{ lib
, buildDunePackage
, fetchFromGitHub
, testVersion
, basls
, menhir
, linol
, linol-lwt
, lsp
, containers
, zarith
, hashcons
, ppx_deriving
, ppxlib
}:

buildDunePackage {
  pname = "basil_lsp";
  version = "0.1.0-unstable-2025-07-11";

  src = fetchFromGitHub {
    owner = "ailrst";
    repo = "basls";
    rev = "04d27999b1beec5bce8ada08e12ffa1625ed176e";
    hash = "sha256-TRWfjcPDAR9PQKFJQ+mqAszwuQ7YcVr2AVzaseMjatE=";
  };

  buildInputs = [ linol linol-lwt lsp containers zarith hashcons ppx_deriving ppxlib ];
  nativeBuildInputs = [ menhir ];

  outputs = [ "out" "dev" ];

  passthru.tests.test-proto-json = testVersion {
    package = basls;
    command = "proto-json.py --help";
    version = "proto-json.py";
  };

  meta = {
    homepage = "https://github.com/ailrst/basls";
    description = "A simple proof of concept language server for Basil IR supporting goto definition and the symbol list for
block and procedure labels";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
