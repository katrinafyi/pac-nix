{ alive2
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-07-18";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "11965749af8e8415932f4e6cc1857b6c570ac951";
    hash = "sha256-8mu0Qg7O+wmJ29zCM61Ut8cCSyb52zP+mtUAqo9zNQs=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
