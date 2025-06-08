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
  version = "0.1.2-alpha-unstable-2025-06-06";

  nativeBuildInputs = [ makeBinaryWrapper jdk haskellPackages.BNFC ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bil-to-boogie-translator";
    rev = "79360525b71b7a0d5460644de23d0418d315717c";
    sha256 = "sha256-e9A/tXtOvwr9VzMbb3i4A21JiLAKy9uu2WStP/q1Owc=";
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

  depsSha256 = "sha256-+zKJ6awe6V/VyLt2Ux5S4rdgEKivho9vx/8INYKAoPo=";
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
