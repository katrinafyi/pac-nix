{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-02-20";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "6d98b047af71479b9247681eda4ecdfef063fb68";
    hash = "sha256-LGLfMg5dFw1qHwKOWWE+lLk43p8GNdMQ+4a2DcIhwTE=";
  };

})
