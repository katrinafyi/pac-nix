{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-02-13";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "fcda62aefb8dc6ebafc2c262a332ceff9d90e136";
    hash = "sha256-XRSuE9u7pIpk+dUf6CZjkVtWSTt5BKgz6jkQTxn8p/o=";
  };

})
