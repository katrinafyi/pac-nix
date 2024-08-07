{ lib
, fetchurl
, fetchFromGitHub
, buildNpmPackage
}:

buildNpmPackage {
  pname = "compiler-explorer-ailrst";
  version = "0-unstable-2024-07-30";

  # https://github.com/ailrst/compiler-explorer/tree/fe7ed875f644a7fc0841382439ebe1f619bff05d
  # https://github.com/ailrst/compiler-explorer/compare/fe7ed875f644a7fc0841382439ebe1f619bff05d...main
  src = fetchFromGitHub {
    owner = "ailrst";
    repo = "compiler-explorer";
    rev = "fe7ed875f644a7fc0841382439ebe1f619bff05d";
    sha256 = "sha256-sZcD8CwO55fQYdxRZmZEgMjao91EOAo7zRzLn6zDRIo=";
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
      --replace out/compiler-cache \''${COMPILER_CACHE} \
      --replace /storage/data \''${LOCAL_STORAGE}

    substituteInPlace etc/config/{c,boogie}.defaults.properties \
      --replace /compiler-explorer/basil-tool.py \''${BASIL_TOOL}

    # https://github.com/compiler-explorer/compiler-explorer/commit/5d776aaae3be2cf07a2442f839812ca6b076df4d
    substituteInPlace package.json \
      --replace 'ts-node-esm ' 'node --no-warnings=ExperimentalWarning --loader ts-node/esm '

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

  meta = {
    homepage = "https://github.com/ailrst/compiler-explorer";
    description = "A fork of godbolt containing the configuration to run BASIL and Boogie IVL";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
