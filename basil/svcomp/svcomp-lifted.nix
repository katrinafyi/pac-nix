{
  fetchFromGitLab
, gcc-aarch64
, clang-aarch64
, asli
, ddisasm
, bap-aslp
, bap-asli-plugin
, gtirb-pprinter
, gtirb-semantics
, pkgsCross
}:
let
  packages = [
    pkgsCross.aarch64-multiplatform.pkgsBuildHost.gcc
    pkgsCross.aarch64-multiplatform.pkgsBuildHost.clang

    pkgsCross.aarch64-multiplatform-musl.pkgsBuildHost.gcc
    pkgsCross.aarch64-multiplatform-musl.pkgsBuildHost.clang

    asli

    bap-aslp
    bap-asli-plugin

    ddisasm
    gtirb-pprinter
    gtirb-semantics
  ];
in 
pkgsCross.aarch64-multiplatform.pkgsBuildHost.stdenv.mkDerivation rec {
  pname = "svcomp-lifted";
  version = "0.0.1";
  src = fetchFromGitLab {
    owner="sosy-lab";
    repo="benchmarking/sv-benchmarks";
    rev="0ea9290d64d1cb37e56b525caacac0c3aaac8015";
    hash="sha256-0EaKuyVYcA3nGZMid/efLoEfQpFFhHE183HnZfrEgKQ=";
  };


  patches = [./patch-rules.patch];
  hardeningDisable = [ "all" ];
  nativeBuildInputs = packages ;
  buildPhase = ''
    export GTIRB_SEM_SOCKET=$(pwd .)/gtirb-sem-socket
    export CC=aarch64-unknown-linux-gnu-gcc
    gtirb-semantics --serve & sleep 3
    for ex in "uthash-2.0.2" ; do
      cp ${./stubs.c} ./c/$ex/stubs.c
      sed -i 's/__float128/_Float128/g' ./c/$ex/*.i
      make -C ./c/$ex SYNTAX_ONLY=0 SUPPRESS_WARNINGS=1 -j8
      make -f ${./lift.mk} -C ./c/bin/$ex -j8
      rm -rf ./c/bin/$ex/*.oi ./bin/$ex/*.di ./bin/$ex/*.oc ./bin/$ex/*.dc
    done
    gtirb-semantics --shutdown-server
  '';
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/examples
    cp -r ./c/bin/* $out/examples

    echo "#!/bin/bash\ncat $out/examples.txt" >> $out/bin/svcomp-list.sh

  '';
}
