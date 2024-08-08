{ lib
, stdenv
, writeShellScript
, bash
, basil-tool
, nodejs
, compiler-explorer
}:

let script =
  writeShellScript "godbolt-script"
    ''
      lib=${compiler-explorer}/lib/node_modules/compiler-explorer
      cd $lib

      export NODE_ENV=production
      export COMPILER_CACHE="''${COMPILER_CACHE:-/tmp/compiler-cache}"
      export LOCAL_STORAGE="''${LOCAL_STORAGE:-$HOME/.local/state/compiler-explorer}"
      export BASIL_TOOL="''${BASIL_TOOL:-${basil-tool}/bin/basil-tool}"
      exec ${nodejs}/bin/node $lib/out/dist/app.js --webpackContent $lib/out/webpack/static "$@"
    '';
in stdenv.mkDerivation {
  pname = "godbolt";
  inherit (compiler-explorer) version src;

  buildInputs = [ bash nodejs ];

  unpackPhase = ":";

  postInstall = ''
    mkdir -p $out/bin
    cp -v "${script}" $out/bin/godbolt
  '';

  meta = {
    homepage = "https://github.com/ailrst/compiler-explorer";
    description = "godbolt wrapper script for compiler-explorer.";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
