{ alive2
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "unstable-2024-07-08";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "4e353ccea4e1d40902f81b186cf3d7056a955d56";
    hash = "sha256-INSVCPmY0Pxo5PFASKN8ClsiN4tBOZkC0d9yFmlj4ak=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
