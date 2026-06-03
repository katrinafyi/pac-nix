{ lib
, fetchFromGitHub
, buildDunePackage
  # ocamlPackages
, lwt
, mtime
, aches
, aslp
, aslp_lifter_ocaml
}:

buildDunePackage {
  pname = "aslp_client_server_ocaml";
  version = "0.1.5-unstable-2026-05-29";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "b3cd2aaf73771a3e43a4ee113c174f7fef238cb5";
    hash = "sha256-3K/DiuYjj7B71GvzzJN/0e4wiCh15l8rbeVpDuk1ypk=";
  };

  checkInputs = [ ];
  nativeCheckInputs = [ ];
  buildInputs = [ ];
  nativeBuildInputs = [ ];
  propagatedBuildInputs = [ aslp lwt mtime aches aslp_lifter_ocaml ];

  doCheck = true;

  outputs = [ "out" "dev" ];

  passthru = { };

  meta = {
    homepage = "https://github.com/UQ-PAC/aslp-rpc";
    description = "RPC connectors for aslp for OCaml and C++ (OCaml Unix socket server component)";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
