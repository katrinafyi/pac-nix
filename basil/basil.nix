{ lib
, fetchFromGitHub
, mkSbtDerivation
, makeBinaryWrapper
, jdk
, jre
, testers
, basil
}:

mkSbtDerivation {
  pname = "basil";
  version = "0.1.2-alpha-unstable-2024-10-14";

  nativeBuildInputs = [ jdk makeBinaryWrapper ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bil-to-boogie-translator";
    rev = "d4dc24a70fd2bfb77edc5ac0cefde6e1bd0bdec1";
    sha256 = "sha256-60ZLRr4yl8wSZ2HuMBqssdW1hjEAavnIOxv/J8zCvzU=";
  };

  depsSha256 = "sha256-++gg+SKskDyaqHowNG2RPS7evuCzPYvvXMC4Rkp7b6U=";

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
