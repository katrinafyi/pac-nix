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
  version = "0-unstable-2025-02-07";

  buildInputs = [ asli js_of_ocaml js_of_ocaml-ppx zarith_stubs_js aslp_offline_js ];
  nativeBuildInputs = [ python3 js_of_ocaml-compiler nodejs-slim nukeReferences ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "aslp-web";
    rev = "7064561055881a6e09d1b00f6ea82bb406d9ec65";
    hash = "sha256-WVR9vhUnQIR2rQVzfNF4+xJJ4Tqxi4HcyDlFG2MgUNA=";
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
