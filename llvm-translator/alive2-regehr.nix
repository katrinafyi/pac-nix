{ alive2
, fetchFromGitHub
, llvmPackages
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "unstable-2024-02-25";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "ee52a684b48e4e8650bb91b1504cafaf7616ec64";
    hash = "sha256-vOIkRC1+1HGPLwOL6QvgvhYRq3CvlAhiAibPT7TYsNI=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
