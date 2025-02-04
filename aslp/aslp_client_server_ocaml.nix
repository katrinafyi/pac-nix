{ lib
, fetchFromGitHub
, buildDunePackage
  # ocamlPackages
, lwt
, mtime
, aslp
, aches
}:

buildDunePackage {
  pname = "aslp_client_server_ocaml";
  version = "0.1.1-unstable-2025-02-04";

  minimalOCamlVersion = "5.0";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "4deea4f561853388dd54fcb2ccae14bd9bbe22e1";
    hash = "sha256-PbZNrFFXNVvnuwTeiDtil6jMKHqPddvTGYpQnnbhJ5Q=";
  };

  checkInputs = [ ];
  nativeCheckInputs = [ ];
  buildInputs = [ ];
  nativeBuildInputs = [ ];
  propagatedBuildInputs = [ aslp lwt mtime aches ];

  doCheck = true;

  outputs = [ "out" "dev" ];

  passthru = { };

  meta = {
    homepage = "https://github.com/UQ-PAC/aslp-rpc";
    description = "RPC connectors for aslp for OCaml and C++ (OCaml Unix socket server component)";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
