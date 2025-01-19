{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-01-17";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "343184fa11ca5d9fb072c9bff5de8a4a5e5a108c";
    hash = "sha256-6rGuB974vTYlYFKokCHgbXi+ECIXLGwBcNQWtcNee1c=";
  };

})
