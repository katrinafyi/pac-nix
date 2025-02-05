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
  version = "0.1.2-unstable-2025-02-05";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "360d4e3e2da0e6801cf90f93903b40e43fd9cbfd";
    hash = "sha256-dGk1S28qdRJaQuLYhBlprV+TBlUd6XE0D+w5TGn4kls=";
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
