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
  version = "0-unstable-2024-07-11";

  buildInputs = prev.buildInputs ++ [ aslp-cpp antlr.runtime.cpp ];
  nativeBuildInputs = prev.nativeBuildInputs ++ [ jre ];

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "alive2";
    rev = "4fc1b579340c9ce5d692e4d4140aa88f7979b971";
    hash = "sha256-fRNUT26zt60lPC3fEQh27x6tYe3oRZ+3IakybEQS0B8=";
  };

  cmakeFlags = prev.cmakeFlags
    ++ [ (lib.cmakeFeature "ANTLR4_JAR_LOCATION" "${antlr.jarLocation}") ];

})
