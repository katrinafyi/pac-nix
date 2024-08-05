{ alive2
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-08-05";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "79c8be559d53148eb00d10d9f6522f08522ebd60";
    hash = "sha256-USuxqiau0u39HBcP1z9N7g3sG9RUlfUd60GRNp6OTaQ=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
