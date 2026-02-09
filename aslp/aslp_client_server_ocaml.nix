{ lib
, fetchFromGitHub
, buildDunePackage
  # ocamlPackages
, lwt
, mtime
, aslp
, aches
, aslp_offline
}:

buildDunePackage {
  pname = "aslp_client_server_ocaml";
  version = "0.1.4-unstable-2026-02-09";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "001b2f954412466fce56c312a9258c3c4698ea6a";
    hash = "sha256-AIAfLaTlXOU7QW2/Pk98pA6FoE0SJtzvXFsfmFCy6Ao=";
  };

  checkInputs = [ ];
  nativeCheckInputs = [ ];
  buildInputs = [ ];
  nativeBuildInputs = [ ];
  propagatedBuildInputs = [ aslp lwt mtime aches aslp_offline ];

  doCheck = true;

  outputs = [ "out" "dev" ];

  passthru = { };

  meta = {
    homepage = "https://github.com/UQ-PAC/aslp-rpc";
    description = "RPC connectors for aslp for OCaml and C++ (OCaml Unix socket server component)";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
