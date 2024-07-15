{ alive2
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-07-15";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "5ef3596e33a06c71b9d16054612d851c9274441f";
    hash = "sha256-Wm1cur+HA7Dt6cqS7KPkhWFyNzuIhM38pm0iZm4V5bg=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
