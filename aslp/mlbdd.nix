{ lib
, fetchFromGitHub
, buildDunePackage
  # ocamlPackages
, ounit
}:

buildDunePackage {
  pname = "mlbdd";
  version = "0.7.2";

  minimalOCamlVersion = "4.01";

  src = fetchFromGitHub {
    owner = "arlencox";
    repo = "mlbdd";
    rev = "v0.7.2";
    hash = "sha256-GRkaUL8LQDdQx9mPvlJIXatgRfen/zKt+nGLiH7Mfvs=";
  };

  checkInputs = [ ounit ];
  nativeCheckInputs = [ ];
  buildInputs = [ ];
  nativeBuildInputs = [ ];
  propagatedBuildInputs = [ ];

  doCheck = true;

  outputs = [ "out" "dev" ];

  meta = {
    homepage = "https://github.com/arlencox/mlbdd";
    description = "A not-quite-so-simple Binary Decision Diagrams implementation for OCaml";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
