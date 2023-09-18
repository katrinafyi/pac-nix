{ stdenv,
  lib,
  fetchpatch,
  fetchFromGitHub,
  cmake, ninja, git, z3, re2c, zlib, ncurses,
  llvm-rtti-eh,
  llvmPackages_15
}:

let _llvm = llvm-rtti-eh.override { llvmPackages = llvmPackages_15; };
in stdenv.mkDerivation rec {
  pname = "alive2";
  version = "2022-10-26";

  src = fetchFromGitHub {
    owner = "AliveToolkit";
    repo = "alive2";
    rev = "bc51b72cf5773967fd29155f1ffb251df4d5e94e";
    sha256 = "sha256-qPH6+QL7X4bUlOwUWWgyQWz+iPNeytGxUp3eG1tKXn0=";
    leaveDotGit = true;
  };

  patchFile = fetchpatch {
    url = "https://github.com/AliveToolkit/alive2/commit/9a7504a99972e2c613deacaa8a4f1798829d2ff2.patch";
    hash = "sha256-6hvG89H0vQBO8SdN76PuphJz4sXSbDImqFtJNCTFetI=";
  };

  nativeBuildInputs = [ cmake ninja git re2c ];
  buildInputs = [ z3 zlib ncurses ];

  cmakeFlags = [ "-DBUILD_TV=1" "-DLLVM_DIR=${_llvm.dev}/lib/cmake/llvm" ];

  patchPhase = ''
    runHook prePatch
    patch --verbose -p1 -u < ${patchFile}
    runHook postPatch
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
