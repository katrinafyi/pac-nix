{ lib
, alive2
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-12-25";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "2728ecaafd0572174150652f9910b73b778c2c1e";
    hash = "sha256-OQw0GYw0PNYtb/d9ZQfHVAhuxi1k6IQJs/pY8IHBxac=";
  };

  patches = [ ];
  CXXFLAGS = (prev.CXXFLAGS or "")
    + lib.optionalString (!stdenv.isDarwin) " -Wno-error=maybe-uninitialized";
})
