{ alive2
, fetchFromGitHub
, llvmPackages
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "unstable-2024-03-03";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "13e370363a0374bfeef84a617acb7653599d647e";
    hash = "sha256-TkpswwyO0A0MFgQvlWV8G7wUIpQxn484pbFONKI0z3E=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
