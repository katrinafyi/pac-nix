{ lib
, stdenv
, fetchurl
, fetchFromGitHub
, buildNpmPackage
, makeBinaryWrapper
, writeShellScript
, testers
, bash
, basil-tool
, nodejs
, godbolt
, bap-aslp
, gcc-aarch64
, clang-aarch64
, boogie
}:

let
  ce-ailrst = buildNpmPackage rec {
    pname = "compiler-explorer-ailrst";
    version = "unstable-2023-09-29";

    # https://github.com/ailrst/compiler-explorer/tree/f92815a06c3e1e442981efd8f5a05e1e5128e859
    # https://github.com/ailrst/compiler-explorer/compare/f92815a06c3e1e442981efd8f5a05e1e5128e859...main
    src = fetchFromGitHub {
      owner = "ailrst";
      repo = "compiler-explorer";
      rev = "01f520cbe8b6cf2cc572f5ca85b716439066e9d1";
      sha256 = "sha256-+gxXfWYrG84Ekp2kVQltPKP1Q0E9gjvWKoP7QQAkfUM=";
    };

    npmDepsHash = "sha256-i2agFqHb1Sr82ZZKgL+97oRYRLgrmbGM5+jU/CtGF2M=";

    patches = [
      (fetchurl {
        url = "https://gist.githubusercontent.com/katrinafyi/e5a6b6d8bed540af46bba8c3cc3d9d08/raw/0001-support-environment-variables-in-properties.patch";
        hash = "sha256-Tpx272FGaSBcScI0ee/4cT3QGI56V1QixKYjL7m1/Q8=";
      })
    ];

    prePatch = ''
      export CYPRESS_INSTALL_BINARY=0
    '';

    dontStrip = false;

    buildPhase = ''
      runHook preBuild

      substituteInPlace etc/config/compiler-explorer.defaults.properties \
        --replace-fail out/compiler-cache \''${COMPILER_CACHE} \
        --replace-fail /storage/data \''${LOCAL_STORAGE}

      substituteInPlace etc/config/boogie.defaults.properties \
        --replace-fail /compiler-explorer/basil-tool.py \''${BASIL_TOOL} \

      substituteInPlace etc/config/c.defaults.properties \
        --replace-fail /compiler-explorer/basil-tool.py \''${BASIL_TOOL} \
        --replace-fail /usr/bin/aarch64-linux-gnu-gcc ${gcc-aarch64}/bin/aarch64-unknown-linux-gnu-gcc \
        --replace-fail /usr/bin/clang-15 ${clang-aarch64}/bin/aarch64-unknown-linux-gnu-clang\
        --replace-fail /usr/bin/aarch64-linux-gnu-objdump ${gcc-aarch64}/bin/aarch64-unknown-linux-gnu-objdump \

      # https://github.com/compiler-explorer/compiler-explorer/commit/5d776aaae3be2cf07a2442f839812ca6b076df4d
      substituteInPlace package.json \
        --replace-fail 'ts-node-esm ' 'node --no-warnings=ExperimentalWarning --loader ts-node/esm '

      npm run webpack
      npm run ts-compile
      runHook postBuild
    '';

    preInstall = ''
      npm uninstall --omit=dev --ignore-scripts ts-node monaco-editor monaco-vim @fortawesome/fontawesome-free
    '';

    postInstall = ''
      lib=$out/lib/node_modules/compiler-explorer

      cp -r out $src/package.json $src/package-lock.json $lib
      rm -rf $lib/test $lib/node_modules/.cache
    '';
  };
in
stdenv.mkDerivation rec {
  pname = "godbolt";
  version = ce-ailrst.version;

  buildInputs = [ bash nodejs ];

  unpackPhase = ":";

  script = writeShellScript "godbolt-script"
    ''
      lib=${ce-ailrst}/lib/node_modules/compiler-explorer
      cd $lib

      export PATH="$PATH:${boogie}/bin/:${bap-aslp}/bin:${clang-aarch64}/bin:${gcc-aarch64}/bin"
      export NODE_ENV=production
      export COMPILER_CACHE="''${COMPILER_CACHE:-/tmp/compiler-cache}"
      export LOCAL_STORAGE="''${LOCAL_STORAGE:-$HOME/.local/state/compiler-explorer}"
      export BASIL_TOOL="''${BASIL_TOOL:-${basil-tool}/bin/basil-tool}"
      exec ${nodejs}/bin/node $lib/out/dist/app.js --webpackContent $lib/out/webpack/static "$@"
    '';

  postInstall = ''
    mkdir -p $out/bin
    cp -v "${script}" $out/bin/godbolt
  '';

  passthru = {
    inherit ce-ailrst;
  };
}
