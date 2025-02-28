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
    cat <<EOF >> build.sbt
    PB.protocExecutable := file("${lib.getExe protobuf}")
    EOF
  '';
  mkSbtDerivation' = mkSbtDerivation.withOverrides { sbt = sbt.override { jre = jdk17; }; };
in
mkSbtDerivation' {
  pname = "basil";
  version = "0.1.2-alpha-unstable-2025-02-27";

  nativeBuildInputs = [ makeBinaryWrapper ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bil-to-boogie-translator";
    rev = "a7c77db3e197ada7e24762983d742dcf24bc320c";
    sha256 = "sha256-wX0BqgKq1TywIdZrm2Rl4JXvJU58M9BGCtBq+Ji+9f4=";
  };

  patches = [ ] ;

  # we must run the command in both the main derivation
  # and the dependency-generating derivation.
  overrideDepsAttrs = depsfinal: depsprev: {
    postPatch = replaceProtocPlaceholder;
  };
  postPatch = replaceProtocPlaceholder;

  depsSha256 = "sha256-dbCdvd9j5DaOqAClNgBtTJ996JilEtKvuxvJ3qjdGTQ=";

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
