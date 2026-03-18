{ lib
, fetchFromGitHub
, mkMillDerivation
, makeWrapper
, which
, jq
, jdk
, testers
, basil
, protobuf
, haskellPackages
, runCommand
}:

let
  # postPatch to be shared by deps and main derivation
  postPatchProto = ''
    substituteInPlace build.mill --replace-fail 'ScalaPBModule {' 'ScalaPBModule {
      override def scalaPBProtocPath = Some("${lib.getExe protobuf}")'
  '';
in
mkMillDerivation rec {
  pname = "basil";
  version = "0.1.2-alpha-unstable-2026-03-10";

  nativeBuildInputs = [ makeWrapper jdk haskellPackages.BNFC which jq ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bil-to-boogie-translator";
    rev = "9545402e7739b292e353f1e6259b3d6b6d96a26d";
    sha256 = "sha256-2ax0ETw2Mfcds7nefwdb0GcG/BdKtYmsauQYau7WNvg=";
  };

  patches = [ ];

  # we must run the command in both the main derivation
  # and the dependency-generating derivation.
  overrideDepsAttrs = depsfinal: depsprev: {
    postPatch = postPatchProto;
  };
  postPatch = postPatchProto;

  depsWarmupCommand = ''
    echo "-Dfile.encoding=UTF-8" >> .mill-jvm-opts
    rm -rf src/main/scala src/test
    # ./mill __.prepareOffline --all
    ./mill z3.prepareOffline
    ./mill assembly
    # ./mill ivyDepsTree --withCompile > $SBT_DEPS/project/.tree.txt
  '';

  depsSha256 = "sha256-qp9J/fU2aLh6TMqyZxZIqqqDZqCycM94cRSKPyN6PHA=";
  depsArchivalStrategy = "link";

  buildPhase = ''
    runHook preBuild
    export COMMIT=${version}
    export GITHUB_SHA=${src.rev}
    ./mill assembly
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/basil $out/share/basil

    # copy jar to output directory
    dest=$out/share/basil/basil.jar
    cp -v "out/assembly.dest/out.jar" $dest

    ./mill z3.nativeLibraryPath
    cp -v out/z3/nativeLibraryPath.dest/* $out/lib/basil

    classpath="$(./mill show runClasspath | jq -r 'map(split(":")[-1]) | join(" ")')"

    deps="$(jdeps --ignore-missing-deps --multi-release 17 --recursive --print-module-deps -q $classpath | tail -n1)"

    jlink --add-modules "$deps" --output $jre --compress zip-6 --no-header-files --no-man-pages

    # make wrapper to run jar with appropriate arguments
    makeWrapper "$jre/bin/java" $out/bin/basil \
      --add-flags -Djava.library.path=$out/lib/basil \
      --add-flags -jar \
      --add-flags "$dest"

    runHook postInstall
  '';

  outputs = [ "out" "jre" ];

  meta = {
    homepage = "https://github.com/UQ-PAC/bil-to-boogie-translator";
    description = "Basil static analysis tool to analyse and translate BIR to Boogie.";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };

  passthru.tests.basil-version = testers.testVersion {
    package = basil;
    command = ''basil --version'';
    version = version;
  };

  passthru.tests.basil-verify = runCommand "basil-verify" { nativeBuildInputs = [ basil ]; }
    ''
    basil -i ${basil.src}/src/test/correct/secret_write/gcc/secret_write.gts --lifter --simplify-tv-verify
    touch $out
    '';
}

