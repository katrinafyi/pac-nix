{ alive2
, fetchFromGitHub
, llvmPackages
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "unstable-2024-03-06";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "53976b3d73adb161c98ee16026800108335276c0";
    hash = "sha256-pt+Y0xp1TsNl4gi9tf1G9lHTH0ASdBuZrLEg9zPRdlw=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
