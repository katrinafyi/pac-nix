{ alive2
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-08-28";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "3c961c66ddd177f1800c16756461f5ab072f9f20";
    hash = "sha256-i7sI9seWU0pPNnjrTGtqH6wK1AmIoLIQEuqPBk7pShM=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
