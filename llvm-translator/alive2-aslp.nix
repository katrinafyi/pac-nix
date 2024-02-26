{ lib
, alive2-regehr
, fetchFromGitHub
, aslp-cpp
, antlr
, jre
}:

alive2-regehr.overrideAttrs (prev: {
  pname = "alive2-aslp";
  version = "unstable-2024-02-26";

  buildInputs = prev.buildInputs ++ [ aslp-cpp antlr.runtime.cpp ];
  nativeBuildInputs = prev.nativeBuildInputs ++ [ jre ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "alive2";
    rev = "a6048461bb4c05ec3bfbb41b69b99c6850d7bd0f";
    hash = "sha256-lIX+NIyLsB+oe/rG84/cessXmPN83GloB7BkrekNQBw=";
  };

  cmakeFlags = prev.cmakeFlags
    ++ [ (lib.cmakeFeature "ANTLR4_JAR_LOCATION" antlr.jarLocation) ];

})
