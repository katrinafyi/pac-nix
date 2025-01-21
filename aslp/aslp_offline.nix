{ lib
, fetchFromGitHub
, buildDunePackage
, pcre
, ott
, menhir
, asli
, alcotest
}:

buildDunePackage {
  pname = "aslp_offline";
  version = asli.version;

  minimalOCamlVersion = "4.09";

  src = asli.src;

  checkInputs = [ alcotest asli ];
  nativeCheckInputs = [ ];
  buildInputs = [ asli ];
  nativeBuildInputs = [ asli ];
  propagatedBuildInputs = [ ];

  doCheck = true;

  meta = {
    homepage = "https://github.com/UQ-PAC/aslp";
    description = "ASL offline lifter generated from ARM's MRA.";
    maintainers = with lib.maintainers; [ katrinafyi ];
    mainProgram = "offline_sem";
  };
}
