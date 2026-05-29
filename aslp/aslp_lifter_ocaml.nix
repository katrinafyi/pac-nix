{ lib
, fetchFromGitHub
, buildDunePackage
, aslp
}:

buildDunePackage {
  pname = "aslp_lifter_ocaml";
  version = "1.0.0";

  minimalOCamlVersion = "4.14";

  propagatedBuildInputs = [ aslp ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-lifter-ocaml";
    rev = "1.0.0";
    hash = "sha256-T+Bqnytlasr+KP34rOWpg5dsdOfJKv7WM3j9cpmcj9s=";
  };

  doCheck = true;

  outputs = [ "out" "dev" ];

  meta = {
    homepage = "https://github.com/UQ-PAC/aslp-lifter-ocaml";
    description = " AArch64 offline lifter (pre-generated)";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
