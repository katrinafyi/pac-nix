{ lib
, alive2-regehr
, llvmPackages
, fetchFromGitHub
, aslp-cpp
, antlr
, jre
, perlPackages
, makeWrapper
, runCommand
, alive2-aslp
}:

(alive2-regehr.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-aslp";
  version = "0-unstable-2024-08-19";

  buildInputs = prev.buildInputs ++ [ aslp-cpp antlr.runtime.cpp ];
  nativeBuildInputs = prev.nativeBuildInputs ++ [ jre makeWrapper ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "alive2";
    rev = "986ea78b172eb34aed868fde710a2747b5c9e1bc";
    hash = "sha256-ZvdEtiMIdM9KS81vrQAlK6Jpa1wlbqO99pNKf5J838o=";
  };

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

  passthru.tests.run-arm-tv = runCommand "test-run-arm-tv" {} ''
    rm -rfv logs logs-aslp
    (set +o pipefail; ${alive2-aslp.run-arm-tv}/bin/*.pl 2>&1 | tee /dev/stderr | grep 'please specify')
    touch $out
  '';

})
