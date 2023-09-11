
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
    rev = "e1b435acbd913fe1b33e9fbb3482f5e0ec3a836d";
    sha256 = "sha256-Nfhf4GEf4p4sAmArjqm0KizAxQrUMWapfUNwI0vGyZA=";
  };

  depsSha256 = "sha256-ed6eE4n2YWcCTYmFKy4mCOhJHprAj2tPfVwRw1zdklQ=";

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
