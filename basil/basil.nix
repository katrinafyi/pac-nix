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
  version = "0.1.2-alpha-unstable-2025-04-28";

  nativeBuildInputs = [ makeBinaryWrapper jdk ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bil-to-boogie-translator";
    rev = "7603ae67c451b71af97b2c642a96e9769a70bc9a";
    sha256 = "sha256-GA6ygXHzoCvw3qwRt9yMuK2GnYtfD4EghR6/Vj6Idvk=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/UQ-PAC/BASIL/commit/a1c4f6a733c193214d5ab9bc1e3a46775bb00313.patch";
      hash = "sha256-PkW8RGIhH378fUNvfdvOwH5/sPqJrQFdqgDWcfDXn/Y=";
    })
  ];

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
