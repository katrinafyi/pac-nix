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
  version = "0.1.4-unstable-2026-02-09";

  minimalOCamlVersion = "5.0";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "001b2f954412466fce56c312a9258c3c4698ea6a";
    hash = "sha256-AIAfLaTlXOU7QW2/Pk98pA6FoE0SJtzvXFsfmFCy6Ao=";
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
