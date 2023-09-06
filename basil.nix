
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
    sbt assembly
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/target

    JAR=target/scala-3.1.0/wptool-boogie*.jar

    # copy jar to output directory
    cp -r $JAR $out/share/$(basename $JAR)

    # make wrapper to run jar with appropriate arguments
    makeBinaryWrapper "${jre}/bin/java" $out/bin/basil \
      --add-flags -jar \
      --add-flags "$out/share/$(basename $JAR)"
  '';

  meta = {
    homepage = "https://github.com/UQ-PAC/bil-to-boogie-translator";
    description = "Basil static analysis tool to analyse and translate BIR to Boogie.";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
