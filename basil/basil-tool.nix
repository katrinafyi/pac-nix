{ lib
, fetchFromGitHub
, stdenv
, makeBinaryWrapper
, testers
, python3
, basil-tool
, basil
, jre
, boogie
, bap-aslp
}:

stdenv.mkDerivation rec {
  pname = "basil-tool";
  version = "unstable-2024-09-29";

  # https://github.com/ailrst/compiler-explorer/tree/f92815a06c3e1e442981efd8f5a05e1e5128e859
  # https://github.com/ailrst/compiler-explorer/compare/f92815a06c3e1e442981efd8f5a05e1e5128e859...main
  src = fetchFromGitHub {
    owner = "ailrst";
    repo = "compiler-explorer";
    rev = "fe7ed875f644a7fc0841382439ebe1f619bff05d";
    sha256 = "sha256-sZcD8CwO55fQYdxRZmZEgMjao91EOAo7zRzLn6zDRIo=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  buildInputs = [ python3 ];

  unpackPhase = ":";

  installPhase = ''
        mkdir -p $out/bin

        basiltool=$out/bin/basil-tool

        cp -v $src/basil-tool.py $basiltool
        chmod u+rw $basiltool

        head -n1 $src/basil-tool.py > $basiltool

        # doesn't seem to do anything
        export PATH="$PATH:${boogie}/bin/:${bap-aslp}/bin:${jre}/bin:${basil}/bin"

        cat <<EOF >> $basiltool
    def __raise(e): raise e  # nix
    def __which(x): from shutil import which; p = which(x); return p if p else __raise(FileNotFoundError("'" + x + "' not found in PATH"))  # nix
    EOF

        cat $src/basil-tool.py >> $basiltool

        substituteInPlace $out/bin/basil-tool \
          --replace 'shutil.which(' '__which(' \
          --replace /target/scala-3.1.0/wptool-boogie-assembly-0.0.1.jar \
            ${basil}/share/basil/*.jar
  '';
}
