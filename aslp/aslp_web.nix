{ lib
, fetchFromGitHub
, buildDunePackage
, nix-gitignore
, asli
, js_of_ocaml
, js_of_ocaml-ppx
, js_of_ocaml-compiler
, nodejs-slim
}:

buildDunePackage rec {
  pname = "aslp_web";
  version = "unstable-2024-06-25";

  buildInputs = [ asli js_of_ocaml js_of_ocaml-ppx ];
  nativeBuildInputs = [ js_of_ocaml-compiler nodejs-slim ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "aslp-web";
    rev = "90d1bb472966e915aea252f73b7fe23ed17ae96a";
    hash = "sha256-mPrn1d0jY3VMYgDsDLtIpemyxMyQIM4GPGMCgYWvBb0=";
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
