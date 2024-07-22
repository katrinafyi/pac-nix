{ alive2
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-07-21";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "1737adce49f4a86060b1eafdd2792fd16e8adbb6";
    hash = "sha256-Dgsdi51zB4MIaI1hB/EC3erh+JbQ6Xbw8bks8cp66Ls=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
