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
  version = "unstable-2024-07-06";

  buildInputs = [ asli js_of_ocaml js_of_ocaml-ppx zarith_stubs_js ];
  nativeBuildInputs = [ python3 js_of_ocaml-compiler nodejs-slim ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "aslp-web";
    rev = "1fe909c1a4d58a42aa98188840cd2e5e20d31427";
    hash = "sha256-FXytjFUvAPJW66cWKbSNlLN82/siYKHZxC+ga9ds3e4=";
  };

  postPatch = ''
    export aslp=${asli.name}
    export aslp_commit=${asli.src.rev or "unknown"}
    export aslp_web=$name
    export aslp_web_commit=${src.rev or "unknown"}

    substituteAllInPlace web/index.html
  '';

  meta = {
    homepage = "https://github.com/katrinafyi/aslp-web";
    description = "aslp on the web";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
