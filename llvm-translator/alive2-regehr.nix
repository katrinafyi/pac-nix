{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-05-26";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "c2564d3c0a9771f8f37a2659ef1af55e770a0c67";
    hash = "sha256-nXFYntQjkOMMEaX5fQQR3udHXqE5pxIauL51IatGKxQ=";
  };

})
