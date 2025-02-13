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

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-aslp";
  version = "tag-aslp-before-upstream-squash-unstable-2025-02-05";

  buildInputs = prev.buildInputs ++ [ aslp-cpp antlr.runtime.cpp ];
  nativeBuildInputs = prev.nativeBuildInputs ++ [ jre makeWrapper ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "alive2";
    rev = "e6fcb5aacce5791b74522fc037d76e5901f18ed1";
    hash = "sha256-UpWOXR9sjUVG5ZtIHD8YHF3F3pS5joDI+ikDJEsGtxs=";
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

})
