{ lib
, fetchFromGitHub
, buildDunePackage
, nix-gitignore
, asli
, js_of_ocaml
, js_of_ocaml-ppx
, js_of_ocaml-compiler
, zarith_stubs_js 
, nodejs-slim
, python3
}:

buildDunePackage rec {
  pname = "aslp_web";
  version = "0-unstable-2024-09-04";

  buildInputs = [ asli js_of_ocaml js_of_ocaml-ppx zarith_stubs_js ];
  nativeBuildInputs = [ python3 js_of_ocaml-compiler nodejs-slim ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "aslp-web";
    rev = "0aad94fd3d8ffd1d241af6e7f060d0a186037cf4";
    hash = "sha256-4QH2lPMYHVrMgKIghcg/RQji7aD19nNYFz2/7g2YJoc=";
  };

  postPatch = ''
    export aslp=${asli.name}
    export aslp_commit=${asli.src.rev or "unknown"}
    export aslp_web=$name
    export aslp_web_commit=$(cat COMMIT || echo ${src.rev or "unknown"})

    substituteAllInPlace web/index.html
  '';

  meta = {
    homepage = "https://github.com/katrinafyi/aslp-web";
    description = "aslp on the web";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
