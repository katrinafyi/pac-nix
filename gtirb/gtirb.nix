{ lib
, stdenv
, fetchFromGitHub
, cmake
, python3
, boost
, protobuf
, doxygen
}:

stdenv.mkDerivation {
  pname = "gtirb";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "GrammaTech";
    repo = "gtirb";
    rev = "v2.0.0";
    hash = "sha256-ueoqxm6iXv4JgzR/xkImT+O8xx+7bA2upx1TJ828LLA=";
  };

  buildInputs = [ cmake python3 boost doxygen ];
  propagatedBuildInputs = [ protobuf ];

  cmakeFlags = [ "-DGTIRB_ENABLE_TESTS=OFF" ];

  preConfigure = ''
    export CXXFLAGS="-includeset -Wno-error=unused-result" 
  '';

  meta = {
    homepage = "https://github.com/GrammaTech/gtirb";
    description = "Intermediate Representation for Binary analysis and transformation.";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
