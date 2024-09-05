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
  version = "0-unstable-2024-09-05";

  buildInputs = [ asli js_of_ocaml js_of_ocaml-ppx zarith_stubs_js ];
  nativeBuildInputs = [ python3 js_of_ocaml-compiler nodejs-slim ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "aslp-web";
    rev = "a774047588e45fb51bec1ad38c5476dc5638ded5";
    hash = "sha256-BO8ydUnYUDS1z+jjXYAcf0NBiUv22Dt8jr4BvaWO3e8=";
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
