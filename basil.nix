
{ lib,
  fetchFromGitHub,
  mkSbtDerivation,
  makeBinaryWrapper,
  jdk,
  jre
}:

mkSbtDerivation rec {
  pname = "basil";
  version = src.rev;

  nativeBuildInputs = [ jdk makeBinaryWrapper ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bil-to-boogie-translator";
    rev = "4046201adc5d48e53c88edafb13f167754344956";
    sha256 = "sha256-oJZSEZgfWqE2um7xhZ1WqhuPze/FJGnWie1v4j9sKi4=";
  };

  depsSha256 = "sha256-jjCOODfTgjsAK31RENvSnNnVRHLMIhDgabXBmNXwKUE=";

  buildPhase = ''
    javac -version
    sbt compile
    sbt package
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/target

    JAR=wptool-boogie_3-0.0.1.jar
    SCALA=scala-3.1.0

    CP=$(sbt 'export runtime:fullClasspath')
    CP=''${CP//$(pwd)/$out/share}

    # copy jar to output directory
    cp -r target/$SCALA $out/share/target

    # make wrapper to run jar with appropriate arguments
    makeBinaryWrapper "${jre}/bin/java" $out/bin/basil \
      --append-flags -jar \
      --append-flags "$out/share/target/$SCALA/$JAR" \
      --append-flags -cp \
      --append-flags "$CP"
  '';

  meta = {
    homepage = "https://github.com/UQ-PAC/bil-to-boogie-translator";
    description = "Basil static analysis tool to analyse and translate BIR to Boogie.";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
