{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-08-08";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "1bf98f970e9c082ed081564f075b005e137ccc86";
    hash = "sha256-FuKmp/Q0LHxd1C2oAB1AuDecnvBFjs351ZwNaqLK0+w=";
  };

})
