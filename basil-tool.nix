{ lib,
  fetchFromGitHub,
  stdenv,
  makeBinaryWrapper,
  testers,
  python3,
  basil-tool,

  basil,
}:

stdenv.mkDerivation rec {
  pname = "basil-tool";
  version = "unstable-2023-09-29";

  # https://github.com/ailrst/compiler-explorer/tree/f92815a06c3e1e442981efd8f5a05e1e5128e859
  # https://github.com/ailrst/compiler-explorer/compare/f92815a06c3e1e442981efd8f5a05e1e5128e859...main
  src = fetchFromGitHub {
    owner = "ailrst";
    repo = "compiler-explorer";
    rev = "f92815a06c3e1e442981efd8f5a05e1e5128e859";
    sha256 = "sha256-eKEm87FOlsSH3tgCfnRYC5nKieD8aVPbcTez93XN3wk=";
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
