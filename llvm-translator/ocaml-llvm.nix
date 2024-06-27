{ lib
, fetchFromGitHub
, buildDunePackage
, libllvm
, ctypes
, ctypes-foreign
, zlib
, libxml2
, ncurses
}:

buildDunePackage rec {
  pname = "llvm";
  version = libllvm.version;

  # nativeBuildInputs = [ libllvm ];

  duneSrc = fetchFromGitHub {
    owner = "alan-j-hu";
    repo = "llvm-dune";
    rev = "v${version}";
    hash =
      lib.throwIfNot (version == "14.0.6") "ocaml-llvm libllvm mismatch"
      "sha256-GHxncfthpMTeVdlDhe7shKWJvoa8Ctn5tU4AfOyOS2w=";
    fetchSubmodules = false;
  };

  llvmSrc = libllvm.src;

  srcs = [ duneSrc llvmSrc ];
  sourceRoot = "source";

  buildInputs = [ zlib libxml2 ncurses ];
  propagatedBuildInputs = [ ctypes ctypes-foreign ];

  prePatch = ''
    rm -rf llvm-project
    ln -s ../llvm-src-* llvm-project
  '';

  configurePhase = ''
    runHook preConfigure

    substituteInPlace setup.sh \
      --replace "cp " "cp --no-preserve=mode,ownership " 
      # --replace support_static_mode=true support_static_mode=false

    ./setup.sh ${libllvm.dev}/bin/llvm-config

    runHook postConfigure
  '';

  postBuild = ''
    rm *.install
  '';

}
