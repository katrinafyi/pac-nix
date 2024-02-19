{ lib
, alive2-regehr
, fetchFromGitHub
, aslp-cpp
, antlr
, jre
}:

alive2-regehr.overrideAttrs (prev: {
  pname = "alive2-aslp";
  version = "unstable-2024-02-19";

  buildInputs = prev.buildInputs ++ [ aslp-cpp antlr.runtime.cpp ];
  nativeBuildInputs = prev.nativeBuildInputs ++ [ jre ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "alive2";
    rev = "df11ee0fe4cb5647de38da7d623593acc6e722d6";
    hash = "sha256-srVjqunp2nK81HfLEla2wkL1tdWfRW/qZkml2cdJ5VY=";
  };

  cmakeFlags = prev.cmakeFlags
    ++ [ (lib.cmakeFeature "ANTLR4_JAR_LOCATION" antlr.jarLocation) ];

})
