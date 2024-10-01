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
  patches = if stdenv.isDarwin then [ ./0001-gtirb-link-absl.patch ] else [];

  nativeBuildInputs = [ ];
  buildInputs = [ cmake python3 boost doxygen ];
  propagatedBuildInputs = [ protobuf ];

  cmakeFlags = [
    "-DGTIRB_ENABLE_TESTS=OFF"
    "-DGTIRB_PY_API=ON"
    "-DGTIRB_RUN_CLANG_TIDY=OFF"
    # "-DCLANG_TIDY_EXE=${lib.getExe' clang-tools "clang-tidy"}"
  ];

  CXXFLAGS = "-includeset -Wno-error=unused-result -Wno-error=array-bounds";
  preConfigure = ''
    substituteInPlace CMakeLists.txt \
      --replace '$'{PYTHON_VERSION} ${python3.version}
    
    substituteInPlace src/CMakeLists.txt src/gtirb/proto/CMakeLists.txt \
      --replace 'DESTINATION lib' 'DESTINATION ''${CMAKE_INSTALL_LIBDIR}' \
      --replace 'DESTINATION include' 'DESTINATION ''${CMAKE_INSTALL_INCLUDEDIR}'
  '';

  postInstall = ''
    # note: pwd is build/
    mkdir -p $python
    cp -rv python $src/*.md $src/*.txt "$python"

    # move gtirbConfig.cmake to $dev
    mkdir -p $dev/lib
    mv -v $out/lib/gtirb $dev/lib
  '';

  outputs = [ "out" "lib" "dev" "python" ];

  meta = {
    homepage = "https://github.com/GrammaTech/gtirb";
    description = "Intermediate Representation for Binary analysis and transformation.";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
