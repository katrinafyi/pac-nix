{ lib
, buildDunePackage
, fetchFromGitHub
, pkgs
, asli
, bisect_ppx
, ppx_inline_test
}:

buildDunePackage {
  pname = "zarith_stubs_js";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "janestreet";
    repo = "zarith_stubs_js";
    rev = "v0.17.0";
    hash = "sha256-QNhs9rHZetwgKAOftgQQa6aU8cOux8JOe3dBRrLJVh0=";
  };

  meta = {
    homepage = "https://github.com/janestreet/zarith_stubs_js";
    description = "Javascripts stubs for the Zarith library";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
