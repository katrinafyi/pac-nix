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
  version = "0.1.2-alpha-unstable-2025-03-24";

  nativeBuildInputs = [ makeBinaryWrapper ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bil-to-boogie-translator";
    rev = "cac748ddcc8e9b611fa2bd372e65043d0a06e5a7";
    sha256 = "sha256-ASOsE4MJylrazNU2QD5BpmPPFbmLzc8I1t2+GpVF2PQ=";
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
