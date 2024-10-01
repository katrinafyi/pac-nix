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

mkSbtDerivation {
  pname = "basil";
  version = "0.1.2-alpha-unstable-2024-09-24";

  nativeBuildInputs = [ jdk makeBinaryWrapper ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bil-to-boogie-translator";
    rev = "4fb69f108427b6b78ad9ee98744364eabf4b2178";
    sha256 = "sha256-juCX3X8KRGLIUqhNcGHUb/nRv09xhWs5cv/wbAs8wmM=";
  };

  patches = [ ./0001-basil-protoc-version.patch ] ;

  preConfigure = ''
    substituteInPlace build.sbt \
      --replace 'PROTOC_PLACEHOLDER' '${protobuf}/bin/protoc'
  '';

  depsSha256 = "sha256-Cyz4kpyZ3KlUo0JmQzvgptSQMErC5G4e8Mp0dWJMaMY";

  buildPhase = ''
    javac -version
    sbt assembly
  '';

  installPhase = ''
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
