{ lib
, alive2-regehr
, llvmPackages
, fetchFromGitHub
, aslp-cpp
, antlr
, jre
}:

(alive2-regehr.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-aslp";
  version = "0-unstable-2024-08-01";

  buildInputs = prev.buildInputs ++ [ aslp-cpp antlr.runtime.cpp ];
  nativeBuildInputs = prev.nativeBuildInputs ++ [ jre ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "alive2";
    rev = "a6667270dec525bc8df954b348f72164b6497c58";
    hash = "sha256-0LhCDi6/f2tSiXs0CYkKYaKjeBHkfL5q6cw25HJSPbE=";
  };

  cmakeFlags = prev.cmakeFlags
    ++ [ (lib.cmakeFeature "ANTLR4_JAR_LOCATION" "${antlr.jarLocation}") ];

})
