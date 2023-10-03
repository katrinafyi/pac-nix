
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
  version = "unstable-2023-10-03";

  nativeBuildInputs = [ jdk makeBinaryWrapper ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bil-to-boogie-translator";
    rev = "049af3b5fb0fd1c8785a09500b05bbbaa946bf0f";
    sha256 = "sha256-qMOOx4SDMtdigPp9mPTn/BIGjCEAbYDZafj9KOGUBxQ=";
  };

  depsSha256 = "sha256-ed6eE4n2YWcCTYmFKy4mCOhJHprAj2tPfVwRw1zdklQ=";

  buildPhase = ''
    javac -version
    sbt assembly
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/basil

    JAR=target/scala-3.1.0/wptool-boogie*.jar

    # copy jar to output directory
    cp -r $JAR $out/share/basil/$(basename $JAR)

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
