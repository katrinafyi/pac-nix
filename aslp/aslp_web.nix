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
    rev = "179cd92d0e3d20c679cd5e81cbc62c7946f5da11";
    hash = "sha256-sJB30njmueLOP2JA0CWTpn/ZVXol5rzqPkakDuk0+Io=";
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
