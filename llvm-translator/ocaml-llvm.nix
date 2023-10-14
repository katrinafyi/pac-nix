{ lib,
  fetchFromGitHub,
  pkgs,
  ocamlPackages,
  libllvm,

  zlib,
  libxml2,
  ncurses,
}:

ocamlPackages.buildDunePackage rec {
  pname = "llvm";
  version = "14.0.6";

  nativeBuildInputs = [ libllvm ];

  duneSrc = fetchFromGitHub {
    owner = "alan-j-hu";
    repo = "llvm-dune";
    rev = "v${version}";
    hash = "sha256-GHxncfthpMTeVdlDhe7shKWJvoa8Ctn5tU4AfOyOS2w=";
    fetchSubmodules = false;
  };

  llvmSrc = lib.throwIfNot (libllvm.version == version)
    "ocaml-llvm: versions must match (got: ${libllvm.version}, ${version})"
    libllvm.src;

  srcs = [ duneSrc llvmSrc ];
  sourceRoot = "source";

  buildInputs = [ zlib libxml2 ocamlPackages.ctypes ncurses ];

  prePatch = ''
    rm -rf llvm-project
    ln -s ../llvm-src-* llvm-project
  '';

  configurePhase = ''
    runHook preConfigure

    substituteInPlace setup.sh \
      --replace "cp " "cp --no-preserve=mode,ownership " \
      --replace support_static_mode=true support_static_mode=false

    ./setup.sh ${libllvm.dev}/bin/llvm-config

    runHook postConfigure
  '';

  postBuild = ''
    rm *.install
  '';

}
