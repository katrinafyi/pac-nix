{ lib
, fetchFromGitHub
, mkSbtDerivation
, makeBinaryWrapper
, jdk
, jre
, testers
, basil
, protobuf
}:

let
  replaceProtocPlaceholder = ''
    substituteInPlace build.sbt \
      --replace-fail 'PROTOC_PLACEHOLDER' '${lib.getExe protobuf}'
  '';
in
mkSbtDerivation {
  pname = "basil";
  version = "0.1.2-alpha-unstable-2024-10-30";

  nativeBuildInputs = [ jdk makeBinaryWrapper ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bil-to-boogie-translator";
    rev = "7849e7220d2863b5ecdf100f9c29255aa89a6ecc";
    sha256 = "sha256-gAeoWKLG2xLIK6T0dwQA73YE6LqTO3EoDvbHUT73uSU=";
  };

  patches = [ ./0001-basil-protoc-version.patch ] ;

  # we must run the command in both the main derivation
  # and the dependency-generating derivation.
  overrideDepsAttrs = depsfinal: depsprev: {
    postPatch = replaceProtocPlaceholder;
  };
  postPatch = replaceProtocPlaceholder;

  depsSha256 = "sha256-tDJuleKVLMPCZNJGNxokuScDOU4siLQEmM1FZff+5oM=";

  buildPhase = ''
    runHook preBuild

    javac -version
    sbt assembly

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/basil

    JAR="$(echo target/scala*/wptool-boogie*.jar)"

    if ! [[ -f "$JAR" ]]; then
      echo "ERROR: basil jar file not found!" >&2
      ls -l target/scala*
      false
    fi

    # copy jar to output directory
    cp -v "$JAR" $out/share/basil/$(basename $JAR)

    # make wrapper to run jar with appropriate arguments
    makeWrapper "${lib.getExe jre}" $out/bin/basil \
      --add-flags -jar \
      --add-flags "$out/share/basil/$(basename $JAR)"

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
