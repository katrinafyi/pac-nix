{ lib
, buildDunePackage
, fetchFromGitHub
, asli
, yojson
, cohttp-lwt-unix
}:

buildDunePackage {
  pname = "aslp_server";
  version = "0-unstable-2024-09-24";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp";
    rev = "cf0cc900e8278d16d7886154ea9751a3dd97b7b0";
    hash = "sha256-EA2zHzvRZKAiZTysZQQ2+GI9L6zUNvEqucf5EEqxfy4=";
  };

  buildInputs = [ asli yojson cohttp-lwt-unix ];
  propagatedBuildInputs = [ asli yojson cohttp-lwt-unix ];

  outputs = [ "out" "dev" ];

  meta = {
    homepage = "https://github.com/UQ-PAC/aslp";
    description = "REST server for aslp lifter";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
