{ lib
, fetchFromGitHub
, buildDunePackage
, nix-gitignore
, asli
, js_of_ocaml
, js_of_ocaml-ppx
, js_of_ocaml-compiler
, nodejs-slim
, python3
}:

buildDunePackage rec {
  pname = "aslp_web";
  version = "unstable-2024-06-28";

  buildInputs = [ asli js_of_ocaml js_of_ocaml-ppx ];
  nativeBuildInputs = [ python3 js_of_ocaml-compiler nodejs-slim ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "aslp-web";
    rev = "46241099742be60f644d05be475c60166f944a55";
    hash = "sha256-bOiYHpKYmPcvSlZ2kLT/X8xuNDYRJoS+PbkHUKykXKE=";
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
