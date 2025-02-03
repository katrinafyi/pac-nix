{ lib
, fetchFromGitHub
, buildDunePackage
  # ocamlPackages
, lwt
, mtime
, aslp
}:

buildDunePackage {
  pname = "aslp_client_server_ocaml";
  version = "0.0";

  minimalOCamlVersion = "5.0";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "4670a3c94b6dcaf2b0403b655e3f640b355ef578";
    hash = "sha256-hIELzXYr6uMWijeBZ6Rhip9JCronn2JLiJJsijzRjco=";
  };

  checkInputs = [ ];
  nativeCheckInputs = [ ];
  buildInputs = [ ];
  nativeBuildInputs = [ ];
  propagatedBuildInputs = [ aslp lwt mtime ];

  doCheck = true;

  outputs = [ "out" "dev" ];

  passthru = { };

  meta = {
    homepage = "https://github.com/UQ-PAC/aslp-rpc";
    description = "RPC connectors for aslp for OCaml and C++ (OCaml Unix socket server component)";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
