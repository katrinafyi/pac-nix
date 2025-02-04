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
  version = "0.1.1-unstable-2025-02-04";

  minimalOCamlVersion = "5.0";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "9ae165336d70e8f0c8aaf075fdfb02d86de11097";
    hash = "sha256-3p8WNnbwA//y3Vf5VbibGcZUfU0IBtCRzXCLM1RZeps=";
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
