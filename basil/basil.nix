{ lib
, fetchFromGitHub
, mkMillDerivation
, makeBinaryWrapper
, fetchpatch
, jdk17
, testers
, basil
, protobuf
}:

let
  # postPatch to be shared by deps and main derivation
  postPatch = ''
    substituteInPlace build.sc --replace-fail 'ScalaPBModule {' 'ScalaPBModule {
      override def scalaPBProtocPath = Some("${lib.getExe protobuf}")'
  '';
in
mkMillDerivation {
  pname = "basil";
  version = "0.1.2-alpha-unstable-2025-05-05";

  nativeBuildInputs = [ makeBinaryWrapper jdk17 ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bil-to-boogie-translator";
    rev = "eebe343ea591dcc814595288e804e5c3023f36b4";
    sha256 = "sha256-tJHPRw+FSNMduccCJrJ8azMf4lVMuDYtdGQgP/kQcVk=";
  };

  patches = [ ];

  # we must run the command in both the main derivation
  # and the dependency-generating derivation.
  overrideDepsAttrs = depsfinal: depsprev: {
    postPatch = postPatch;
  };
  postPatch = postPatch;

  depsWarmupCommand = ''
    echo "-Dfile.encoding=UTF-8" >> .mill-jvm-opts
    rm -rf src/main/scala src/test
    ./mill __.prepareOffline --all
    ./mill compile
    ./mill ivyDepsTree --withCompile > $SBT_DEPS/project/.tree.txt
  '';

  depsSha256 = "sha256-t20K0BdLdqvX6sGHE1sJBMJdIiI8K/Bndf052Oi2Y3I=";
  depsArchivalStrategy = "link";

  buildPhase = ''
    runHook preBuild
    ./mill assembly
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/basil

    # copy jar to output directory
    dest=$out/share/basil/basil.jar
    cp -v "out/assembly.dest/out.jar" $dest

    # make wrapper to run jar with appropriate arguments
    makeWrapper "${lib.getExe jdk17}" $out/bin/basil \
      --add-flags -jar \
      --add-flags "$dest"

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/UQ-PAC/bil-to-boogie-translator";
    description = "Basil static analysis tool to analyse and translate BIR to Boogie.";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };

  passthru.tests.basil-arg = testers.testVersion {
    package = basil;
    command = ''basil --help'';
    version = ''analyse'';
  };
}
