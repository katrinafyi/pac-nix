{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-02-19";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "12d57609553518d00b31e3d5ae2cc5e1d46fa455";
    hash = "sha256-D4bENaQKqtNr3ZE8keoX6B2pAnol+/PPzAO302DYlF4=";
  };

})
