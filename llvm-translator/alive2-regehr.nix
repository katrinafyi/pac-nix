{ alive2
, fetchFromGitHub
, llvmPackages
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "unstable-2024-03-04";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "d2efee1b4245c5314a33e8bc1efc17ad392c954d";
    hash = "sha256-MQIO9tZ9hMrzekjWFsVlKuCdD1FAyUZZg201kChDa/8=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
