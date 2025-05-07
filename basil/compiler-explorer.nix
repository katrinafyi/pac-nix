{ lib
, fetchurl
, fetchFromGitHub
, buildNpmPackage
, writeShellScript
, nodejs
, fetchpatch
, makeWrapper
, husky
}:

buildNpmPackage {
  pname = "compiler-explorer-ailrst";
  version = "0-unstable-2024-07-30";

  nativeBuildInputs = [ makeWrapper husky ];

  # https://github.com/ailrst/compiler-explorer/tree/fe7ed875f644a7fc0841382439ebe1f619bff05d
  # https://github.com/ailrst/compiler-explorer/compare/fe7ed875f644a7fc0841382439ebe1f619bff05d...main
  src = fetchFromGitHub {
    owner = "rina-forks";
    repo = "compiler-explorer";
    rev = "eeae9c326d0da0f1d81a8f0add6d598928003333";
    sha256 = "sha256-7wLhdp2ozEjOkYSt6/RbZTXIe7PhLk4beLrdPVnsHYs=";
  };

  npmDepsHash = "sha256-3tt+k6ruIzDKeMTfXM6CkPpkCdwVawbOzFwCCxhdltQ=";

  patches = [
    (fetchpatch {
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

    cat <<'EOF' >etc/config/compiler-explorer.local.properties
    cacheConfig=InMemory(50)
    executableCacheConfig=InMemory(50)
    compilerCacheConfig=OnDisk(/tmp/out/compiler-cache,1024)
    localStorageFolder=''${LOCAL_STORAGE}
    EOF

    npm run webpack
    npm run ts-compile
    runHook postBuild
  '';

  preInstall = ''
    npm uninstall --omit=dev --ignore-scripts ts-node monaco-editor monaco-vim @fortawesome/fontawesome-free
  '';

  postInstall = ''
    lib=$out/lib/node_modules/compiler-explorer
    mkdir -p $out/bin

    cp -r etc out $src/package.json $src/package-lock.json $lib
    rm -rf $lib/test $lib/node_modules/.cache

    makeWrapper ${lib.getExe nodejs} $out/bin/compiler-explorer \
      --set-default NODE_ENV production \
      --set-default LOCAL_STORAGE ./compiler-explorer-storage \
      --chdir $lib \
      --add-flags "$lib/out/dist/app.js --webpackContent $lib/out/webpack/static"
  '';

  meta = {
    homepage = "https://github.com/ailrst/compiler-explorer";
    description = "A fork of godbolt containing the configuration to run BASIL and Boogie IVL";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
