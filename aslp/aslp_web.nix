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
  version = "0-unstable-2024-08-03";

  buildInputs = [ asli js_of_ocaml js_of_ocaml-ppx zarith_stubs_js ];
  nativeBuildInputs = [ python3 js_of_ocaml-compiler nodejs-slim ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "aslp-web";
    rev = "7811cb9755d92a9c12d32448ea0cb45dc272deeb";
    hash = "sha256-LB89ESLzIOePihYEVzaUK219Kn9x6VCn6o1usRFRBSo=";
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
