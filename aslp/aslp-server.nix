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
  version = "0-unstable-2025-02-03";

  minimalOCamlVersion = "5.0";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "12a5dfbda19429cc0c52f941ef67d184b227e3a4";
    hash = "sha256-zsqdxE6HqqSZ86rMF32yTzUEz97mywSKrn3qndmxrDI=";
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
