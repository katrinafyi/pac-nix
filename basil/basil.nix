{ lib,
  fetchFromGitHub,
  mkSbtDerivation,
  makeBinaryWrapper,
  jdk,
  jre,
  testers,
  basil
}:

mkSbtDerivation rec {
  pname = "basil";
  version = "unstable-2023-11-01";

  nativeBuildInputs = [ jdk makeBinaryWrapper ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bil-to-boogie-translator";
    rev = "5f02a105c25e3ee7cecb935c310d572ff7d8d6d1";
    sha256 = "sha256-WiGwGIIZ1M01fNmccKNGG2W2ZJbTzyLv/8MJa9tKyvw=";
  };

  depsSha256 = "sha256-AoHPd8UI0Iprin1Sq7rL0fe+42x8+fNCRYA1bW+5ySQ=";

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
    makeBinaryWrapper "${jre}/bin/java" $out/bin/basil \
      --add-flags -jar \
      --add-flags "$out/share/basil/$(basename $JAR)"
  '';

  meta = {
    homepage = "https://github.com/UQ-PAC/bil-to-boogie-translator";
    description = "Basil static analysis tool to analyse and translate BIR to Boogie.";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };

  passthru.tests.basil-arg = testers.testVersion {
    package = basil;
    command = ''basil --help'';
    version = ''analyse'';
  };
}
