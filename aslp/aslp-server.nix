{ lib
, fetchFromGitHub
, buildDunePackage
  # pkgs
  # ocamlPackages
, eio
, eio_main
, cohttp
, cohttp-eio
  # for testing
, aslp
, aslp-server
, testers
}:

buildDunePackage {
  pname = "aslp_server_http";
  version = "0.1.5-unstable-2026-05-29";

  minimalOCamlVersion = "5.0";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "b3cd2aaf73771a3e43a4ee113c174f7fef238cb5";
    hash = "sha256-3K/DiuYjj7B71GvzzJN/0e4wiCh15l8rbeVpDuk1ypk=";
  };

  checkInputs = [ ];
  nativeCheckInputs = [ ];
  buildInputs = [ aslp eio eio_main cohttp cohttp-eio ];
  nativeBuildInputs = [ ];
  propagatedBuildInputs = [ ];

  doCheck = true;

  postInstall = ''
    mv $out/bin/{aslp_server_http,aslp-server} -v
  '';

  outputs = [ "out" "dev" ];

  passthru = {
    tests.aslp-server = testers.testVersion {
      package = aslp-server;
      command = "command -v ${aslp-server.meta.mainProgram}";
      version = "aslp-server";
    };
  };

  meta = {
    homepage = "https://github.com/UQ-PAC/aslp-rpc";
    description = "RPC connectors for aslp for OCaml and C++ (OCaml HTTP server component)";
    maintainers = with lib.maintainers; [ katrinafyi ];
    mainProgram = "aslp-server";
  };
}
