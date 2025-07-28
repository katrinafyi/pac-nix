{ lib
, buildDunePackage
, fetchFromGitHub
, testVersion
, basls
, linol
, linol-lwt
, lsp
, containers
, zarith
, hashcons
, ppx_deriving
}:

buildDunePackage {
  pname = "basil_lsp";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ailrst";
    repo = "basls";
    rev = "499f19cd30bdde5be4a6612771a0a3a3a37c483a";
    hash = "sha256-qof9cjPAkZu+mVibOUzM9lzeAmq0NEK58oqP9u1EopA=";
  };

  buildInputs = [ linol linol-lwt lsp containers zarith hashcons ppx_deriving ];

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
