{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2026-01-21";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "9d7d458634ed3e48732bf7b56280feb838801292";
    hash = "sha256-g3WKL+9/Lxk6GPKahMUKOwFol/l9Amxe/8Q3zQtdNIQ=";
  };

})
