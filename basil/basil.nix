{ lib
, fetchFromGitHub
, mkMillDerivation
, makeBinaryWrapper
, fetchpatch
, jdk
, jre
, testers
, basil
, protobuf
, haskellPackages
}:

let
  # postPatch to be shared by deps and main derivation
  postPatch = ''
    substituteInPlace build.mill --replace-fail 'ScalaPBModule {' 'ScalaPBModule {
      override def scalaPBProtocPath = Some("${lib.getExe protobuf}")'
  '';
in
mkMillDerivation {
  pname = "basil";
  version = "0.1.2-alpha-unstable-2025-07-03";

  nativeBuildInputs = [ makeBinaryWrapper jdk haskellPackages.BNFC ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bil-to-boogie-translator";
    rev = "090dbd5027a9cef223636b36d83fdc4339bbaca1";
    sha256 = "sha256-yRYaZCMubPbaiiRsODCWwl/jQ3AWuquvCNOSH6dWZOQ=";
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
    # ./mill __.prepareOffline --all
    ./mill assembly
    # ./mill ivyDepsTree --withCompile > $SBT_DEPS/project/.tree.txt
  '';

  depsSha256 = "sha256-VmSwBt36gpgfohOSwbFl0wkCeGLfb25RiW06WjvTjFk=";
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
    makeWrapper "${lib.getExe' jre "java"}" $out/bin/basil \
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
