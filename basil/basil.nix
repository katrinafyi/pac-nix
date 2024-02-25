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
  version = "unstable-2024-02-22";

  nativeBuildInputs = [ jdk makeBinaryWrapper ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bil-to-boogie-translator";
    rev = "c5d396a583868427e763bbd5e000731f1dadb48a";
    sha256 = "sha256-mL/tzW3msiq8LqhdX8HPvFsr40M0kFyHA6bU1R8IGG0=";
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
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };

  passthru.tests.basil-arg = testers.testVersion {
    package = basil;
    command = ''basil --help'';
    version = ''analyse'';
  };
}
