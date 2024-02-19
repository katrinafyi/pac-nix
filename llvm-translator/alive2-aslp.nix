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
    rev = "44e45b7552826891a8e0d7817ed0e4443250c350";
    hash = "sha256-LTmd7jAK6OTWSvqDoEr2arUwsffwDgp3TX45vcDjJ+c=";
  };

  cmakeFlags = prev.cmakeFlags
    ++ [ (lib.cmakeFeature "ANTLR4_JAR_LOCATION" antlr.jarLocation) ];

})
