{ stdenv
, lib
, fetchpatch
, fetchFromGitHub
, cmake
, ninja
, git
, z3
, re2c
, zlib
, ncurses
, llvmPackages
, git-am-shim
, overrideCC
, llvmPackages_17
}:

let buildStdenv = if stdenv.isDarwin then overrideCC stdenv llvmPackages_17.clang else stdenv; in

buildStdenv.mkDerivation {
  pname = "alive2";
  version = "2022-10-26";

  src = fetchFromGitHub {
    owner = "AliveToolkit";
    repo = "alive2";
    rev = "bc51b72cf5773967fd29155f1ffb251df4d5e94e";
    hash = "sha256-gFJOdn+zI0e72FgUFyuGbqWI4qGU/LUKJBbQGwUqu68=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/AliveToolkit/alive2/commit/9a7504a99972e2c613deacaa8a4f1798829d2ff2.patch";
      hash = "sha256-6hvG89H0vQBO8SdN76PuphJz4sXSbDImqFtJNCTFetI=";
    })
  ];

  nativeBuildInputs = [ cmake ninja git re2c ];
  buildInputs = [ z3 zlib ncurses llvmPackages.libllvm ];

  cmakeFlags = [ "-DBUILD_TV=1" "-DGIT_EXECUTABLE=${git-am-shim}" ];
  CXXFLAGS = "-Wno-error=cpp";

  postPatch = ''
    substituteInPlace scripts/alivecc.in \
      --replace '@LLVM_BINARY_DIR@/bin/clang++' ${lib.getBin llvmPackages.clang}/bin/clang++ \
      --replace '@LLVM_BINARY_DIR@/bin/clang' ${lib.getBin llvmPackages.clang}/bin/clang
  '';

  installPhase = ''
    runHook preInstall

    ninja install

    mkdir -p $out/bin
    for f in *; do
      if [[ -x $f ]] && [[ ! -d $f ]]; then
        cp -v $f $out/bin/$f
      fi
    done

    runHook postInstall
  '';
}
