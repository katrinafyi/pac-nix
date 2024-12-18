{ lib
, stdenv
, fetchurl
, fetchFromGitHub
, cmake
, python3
, boost
, protobuf
, doxygen
}:

stdenv.mkDerivation {
  pname = "gtirb";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "GrammaTech";
    repo = "gtirb";
    rev = "v2.2.0";
    hash = "sha256-dzkVwQ7MvVm4KUX/Lo03yd1P9OHj+q1/kp4ZpdO8NDk=";
  };

  patches = [
    (fetchurl {
      url = "https://github.com/rina-forks/gtirb/compare/master..det.patch";
      hash = "sha256-86cRmnV5CL5DjOzFj+cJYUYKQpHQ6DsqnZDaMGa/kog=";
    })
  ] ++ lib.optional stdenv.isDarwin ./0001-gtirb-link-absl.patch;

  postPatch = ''
    (
    shopt -u globstar
    substituteInPlace include/gtirb/{CFG,Module}.hpp --replace-warn unordered_map map --replace-warn unordered_set set
    )
  '';

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
      --replace-warn '$'{PYTHON_VERSION} ${python3.version}
    
    substituteInPlace src/CMakeLists.txt src/gtirb/proto/CMakeLists.txt \
      --replace-fail 'DESTINATION lib' 'DESTINATION ''${CMAKE_INSTALL_LIBDIR}' \
      --replace-warn 'DESTINATION include' 'DESTINATION ''${CMAKE_INSTALL_INCLUDEDIR}'
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
