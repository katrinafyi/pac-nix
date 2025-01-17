{ lib
, fetchFromGitHub
, mkSbtDerivation
, makeBinaryWrapper
, sbt
, jdk17
, testers
, basil
, protobuf
}:

let
  replaceProtocPlaceholder = ''
    substituteInPlace build.sbt \
      --replace-fail 'PROTOC_PLACEHOLDER' '${lib.getExe protobuf}'
  '';
  mkSbtDerivation' = mkSbtDerivation.withOverrides { sbt = sbt.override { jre = jdk17; }; };
in
mkSbtDerivation' {
  pname = "basil";
  version = "0.1.2-alpha-unstable-2025-01-16";

  nativeBuildInputs = [ makeBinaryWrapper ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bil-to-boogie-translator";
    rev = "33c8c3b2d519f93b4b0127775fb0f590b0939409";
    sha256 = "sha256-yXQi2UYbSBUVMC1lc/66CPLZVvXiG9bAnpa2ADVW/Jo=";
  };

  patches = [ ./0001-basil-protoc-version.patch ] ;

  # we must run the command in both the main derivation
  # and the dependency-generating derivation.
  overrideDepsAttrs = depsfinal: depsprev: {
    postPatch = replaceProtocPlaceholder;
  };
  postPatch = replaceProtocPlaceholder;

  depsSha256 = "sha256-KBhHr11b9/Ku2zhuw8wcNefG41IZSSmgC+AeRyvuZ0M=";

  buildPhase = ''
    runHook preBuild

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
    makeWrapper "${lib.getExe jdk17}" $out/bin/basil \
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
