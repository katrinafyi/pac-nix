{ lib
, alive2-aslp
, llvmPackages
, fetchFromGitHub
, aslp-cpp
, antlr
, jre
, perlPackages
, makeWrapper
, runCommand
, alive2
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (final: prev: {
  pname = "alive2-aslp";
  version = "0-unstable-2025-01-14";

  buildInputs = prev.buildInputs ++ [ aslp-cpp antlr.runtime.cpp ];
  nativeBuildInputs = prev.nativeBuildInputs ++ [ jre makeWrapper ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "alive2";
    rev = "78657f9693767952ffad6a9901421dd820386b41";
    hash = "sha256-Sp6+H5SP6gTEY5z0D+nykW4hvMUBGc+RdD5kDTv3tSM=";
  };

  patches = [ ];  # undoing patch needed for upstream alive2

  CXXFLAGS = (prev.CXXFLAGS or "") + " -Wno-error=deprecated-declarations";

  cmakeFlags = prev.cmakeFlags
    ++ [ (lib.cmakeFeature "ANTLR4_JAR_LOCATION" "${antlr.jarLocation}") ];

  postInstall = ''
    ${prev.postInstall or ""}

    mkdir -p $out/bin/scripts

    cp -v ${alive2-aslp.arm-tv-scripts}/bin/* $out/bin/scripts
    chmod -R +rw $out/bin/scripts

    for f in $out/bin/scripts/*; do
      wrapProgram $out/bin/scripts/$(basename $f) \
        --set-default LLVMDIS ${llvmPackages.llvm}/bin/llvm-dis \
        --set-default TIMEOUTBIN $(command -v timeout) \
        --set-default BACKENDTV $out/bin/backend-tv
    done
  '';

  passthru.arm-tv-scripts = perlPackages.buildPerlPackage {
    pname = "run-arm-tv";
    version = alive2-aslp.version;

    src = "${alive2-aslp.src}/backend_tv/scripts";

    propagatedBuildInputs = with perlPackages; [ SysCPU BSDResource ];

    preConfigure = ''
      touch Makefile.PL
    '';

    postInstall = ''
      mkdir -p $out/bin $devdoc
      cp -v *.pl $out/bin
    '';
  };

  # passthru.tests.run-arm-tv = runCommand "test-run-arm-tv" {} ''
  #   rm -rfv logs logs-aslp
  #   set +o pipefail
  #   ${alive2-aslp.arm-tv-scripts}/bin/run-arm-tv.pl 2>&1 | tee /dev/stderr | grep 'please specify'
  #   touch $out
  # '';

  passthru.tests.backend-tv-basic = runCommand "test-backend-tv-basic" {} ''
    ${lib.getExe' final.finalPackage "backend-tv"} ${final.src}/tests/arm-tv/smoketest/x.aarch64.ll
  '';
})
