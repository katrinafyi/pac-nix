{ lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  buildNpmPackage,
  makeBinaryWrapper,
  testers,
  bash,
  basil-tool,

  nodejs,
  godbolt-basil,
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
      rev = "f92815a06c3e1e442981efd8f5a05e1e5128e859";
      sha256 = "sha256-eKEm87FOlsSH3tgCfnRYC5nKieD8aVPbcTez93XN3wk=";
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

    buildPhase = ''
      runHook preBuild

      substituteInPlace etc/config/compiler-explorer.defaults.properties \
        --replace out/compiler-cache \''${COMPILER_CACHE} \
        --replace /storage/data \''${LOCAL_STORAGE}

      substituteInPlace etc/config/{c,boogie}.defaults.properties \
        --replace /compiler-explorer/basil-tool.py \''${BASIL_TOOL}

      npm run webpack
      npm run ts-compile
      runHook postBuild
    '';

    postInstall = ''
      lib=$out/lib/node_modules/compiler-explorer
      cp -r out $lib
    '';
  };
in stdenv.mkDerivation {
  pname = "godbolt-basil";
  version = ce-ailrst.version;

  buildInputs = [ bash nodejs ];

  unpackPhase = ":";

  postInstall = ''
    lib=${ce-ailrst}/lib/node_modules/compiler-explorer

    #	env NODE_ENV=production $(NODE) $(NODE_ARGS) ./out/dist/app.js --webpackContent ./out/webpack/static $(EXTRA_ARGS)

    mkdir -p $out/bin
    cat <<EOF > $out/bin/godbolt
#!/bin/bash

cd $lib
export NODE_ENV=production
export COMPILER_CACHE="\''${COMPILER_CACHE:-/tmp/compiler-cache}"
export LOCAL_STORAGE="\''${LOCAL_STORAGE:-\$HOME/.local/state/compiler-explorer}"
export BASIL_TOOL="\''${BASIL_TOOL:-${basil-tool}/bin/basil-tool}"
exec ${nodejs}/bin/node $lib/out/dist/app.js --webpackContent $lib/out/webpack/static "\$@"
EOF

    chmod a+x $out/bin/godbolt
  '';

  passthru = {
    inherit ce-ailrst;
  };
}
