{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-02-06";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "dfd7a202135e7377d867225b9a8fccedfe3dfae8";
    hash = "sha256-DaTUYZbDzz1wSv20Ycltjd7iTFRdmQcXJ4KiM1CIMCw=";
  };

})
