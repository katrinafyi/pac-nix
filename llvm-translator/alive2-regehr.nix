{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-02-26";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "cf80caba00730552fd8be16182e27b7b3063cd95";
    hash = "sha256-exb8qebDRmJx6iXL6FThNS8XYuMhAX4Kl1yXwKTe58E=";
  };

})
