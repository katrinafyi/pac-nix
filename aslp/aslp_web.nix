{ lib
, fetchFromGitHub
, buildDunePackage
, nix-gitignore
, nukeReferences
, asli
, aslp_offline_js
, js_of_ocaml
, js_of_ocaml-ppx
, js_of_ocaml-compiler
, zarith_stubs_js
, nodejs-slim
, python3
}:

buildDunePackage rec {
  pname = "aslp_web";
  version = "0-unstable-2026-05-29";

  buildInputs = [ asli js_of_ocaml js_of_ocaml-ppx zarith_stubs_js aslp_offline_js ];
  nativeBuildInputs = [ python3 js_of_ocaml-compiler nodejs-slim nukeReferences ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "aslp-web";
    rev = "917974247af7f26762eb9f538a740c6b3993879d";
    hash = "sha256-b17rjmNNgo2KlVAMRDR5xsJDk7yv9b2v7HmKAz4Zl4Y=";
  };

  postPatch = ''
    export aslp=${asli.name}
    export aslp_commit=${asli.src.rev or "unknown"}
    export aslp_web=$name
    export aslp_web_commit=$(cat COMMIT || echo ${src.rev or "unknown"})

    substituteAllInPlace web/index.html
  '';

  postInstall = ''
    find "$out" -type f ! -name dune-package -exec nuke-refs '{}' +
  '';

  meta = {
    homepage = "https://github.com/katrinafyi/aslp-web";
    description = "aslp on the web";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
