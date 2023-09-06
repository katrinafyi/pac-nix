
{ lib,
  fetchFromGitHub,
  mkSbtDerivation,
  jdk
}:

mkSbtDerivation rec {
  pname = "basil";
  version = src.rev;

  nativeBuildInputs = [ jdk ];

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
  '';

  installPhase = ''
    ls -lR target/
    # cp target/my-app.jar $out
    touch $out
  '';

  meta = {
    homepage = "https://github.com/UQ-PAC/bil-to-boogie-translator";
    description = "Basil static analysis tool to analyse and translate BIR to Boogie.";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
