{ lib
, alive2-regehr
, fetchFromGitHub
, aslp-cpp
, antlr
, jre
}:

alive2-regehr.overrideAttrs (prev: {
  pname = "alive2-aslp";
  version = "unstable-2024-03-04";

  buildInputs = prev.buildInputs ++ [ aslp-cpp antlr.runtime.cpp ];
  nativeBuildInputs = prev.nativeBuildInputs ++ [ jre ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "alive2";
    rev = "4dd9b228c8a199efefd7913227adc82a26decf8d";
    hash = "sha256-e5b2Gk//KGMmqsKiHEXTUatjXTauZJPnU55eKAyed9Q=";
  };

  cmakeFlags = prev.cmakeFlags
    ++ [ (lib.cmakeFeature "ANTLR4_JAR_LOCATION" antlr.jarLocation) ];

})
