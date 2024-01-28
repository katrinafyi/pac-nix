{ lib
, stdenv
, fetchFromGitHub
, python3
, cmake
, ninja
, git-am-shim
}:

let
  sleigh-src = fetchFromGitHub {
    owner = "lifting-bits";
    repo = "sleigh";
    rev = "7c6b7424467d0382a1303c278633e99b0d094d5b";
    hash = "sha256-Di/maGPXHPSM/EUVTgNRsu7nJ0Of+tVRu+B4wr9OoBE=";
  };
  # https://github.com/lifting-bits/sleigh/blob/7c6b7424467d0382a1303c278633e99b0d094d5b/src/setup-ghidra-source.cmake
  ghidra-src = fetchFromGitHub {
    owner = "NationalSecurityAgency";
    repo = "ghidra";
    rev = "80ccdadeba79cd42fb0b85796b55952e0f79f323";
    hash = "sha256-7Iv1awZP5lU1LpGqC0nyiMxy0+3WOmM2NTdDYIzKmmk=";
  };

in
stdenv.mkDerivation (self: {
  pname = "sleigh";
  version = "unstable";

  src = sleigh-src;

  nativeBuildInputs = [ python3 cmake ninja ];

  preConfigure = ''
    ghidra=$(mktemp -d)
    cp -r --no-preserve=mode ${ghidra-src}/. $ghidra

    substituteInPlace src/setup-ghidra-source.cmake \
      --replace 'find_package(Git REQUIRED)' "set(GIT_EXECUTABLE ${git-am-shim})" \
      --replace 'GIT_REPOSITORY https://github.com/NationalSecurityAgency/ghidra' "SOURCE_DIR $ghidra"

    echo '
    if(NOT ''${ghidra_head_git_tag} EQUAL ${ghidra-src.rev})
      message(FATAL_ERROR "nix: ghidra hash mismatch (sleigh expected: ''${ghidra_head_git_tag}, nix provided: ${ghidra-src.rev})")
    endif()
    ' >> src/setup-ghidra-source.cmake
  '';

  sleigh_ADDITIONAL_PATCHES = [ ];

  cmakeFlags = [ 
  "-Dsleigh_RELEASE_TYPE=HEAD" 
  "-Dsleigh_ADDITIONAL_PATCHES=${lib.concatStringsSep ";" self.sleigh_ADDITIONAL_PATCHES}" ];
})
