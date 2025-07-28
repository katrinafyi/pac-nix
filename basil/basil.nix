{ lib
, fetchFromGitHub
, mkMillDerivation
, makeBinaryWrapper
, which
, jdk
, jre
, testers
, basil
, protobuf
, haskellPackages
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
  version = "0.1.2-alpha-unstable-2025-07-28";

  nativeBuildInputs = [ makeBinaryWrapper jdk haskellPackages.BNFC which ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bil-to-boogie-translator";
    rev = "6e92b64a3f236a2ab203912bc27a22d0af68ad7b";
    sha256 = "sha256-FPLgXQRhn1n631zZAY3bmYclJCWd+X62mk9Hw+mj8O8=";
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
    ./mill assembly
    # ./mill ivyDepsTree --withCompile > $SBT_DEPS/project/.tree.txt
  '';

  depsSha256 = "sha256-5PxJAAI6z7kIeHcz6tU3NXpZ6mFJXnOtOob2ro5XdoA=";
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

  passthru.tests.basil-version = testers.testVersion {
    package = basil;
    command = ''basil --version'';
    version = version;
  };
}
