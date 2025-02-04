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
  version = "0-unstable-2025-02-03";

  minimalOCamlVersion = "5.0";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "de0567e45af766e03795a757a5a6198efa59d3fe";
    hash = "sha256-Qcn+UmB0SGXUDOCwHkipW857RfYxM6YMfSZJM7uFcF8=";
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
