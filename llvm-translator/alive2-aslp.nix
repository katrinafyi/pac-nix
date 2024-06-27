{ lib
, alive2-regehr
, fetchFromGitHub
, aslp-cpp
, antlr
, jre
}:

alive2-regehr.overrideAttrs (prev: {
  pname = "alive2-aslp";
  version = "unstable-2024-03-12";

  buildInputs = prev.buildInputs ++ [ aslp-cpp antlr.runtime.cpp ];
  nativeBuildInputs = prev.nativeBuildInputs ++ [ jre ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "alive2";
    rev = "6e4c57d5b649c56c36f48078da2ce43da3eb7af0";
    hash = "sha256-5R1htBcfIRGNfVy4rewQEobkro5BXUPWIqQBHqJ+WbY=";
  };

  cmakeFlags = prev.cmakeFlags
    ++ [ (lib.cmakeFeature "ANTLR4_JAR_LOCATION" "${antlr.jarLocation}") ];

})
