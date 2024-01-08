{ lib
, stdenv
, fetchFromGitLab
, cmake
}:

stdenv.mkDerivation {
  pname = "libehp";
  version = "init";

  src = fetchFromGitLab {
    owner = "opensrc";
    repo = "libehp";
    rev = "4d2705bcaa4f9731eabbd5d2dc30bba894432e7c";
    hash = "sha256-uMKb3FO7LGneeznBknfOVkkDHWLEooxQllUjojoE4sU=";
    domain = "git.zephyr-software.com";
  };

  buildInputs = [ cmake ];

  meta = {
    homepage = "https://git.zephyr-software.com/opensrc/libehp";
    description = "Exception handling parsing support for Elf files (eh_frame, etc.)";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}

