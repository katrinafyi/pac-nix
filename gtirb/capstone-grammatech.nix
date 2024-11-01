{ lib
, stdenv
, fetchFromGitHub
, capstone
}:

capstone.overrideAttrs {
  pname = "capstone-grammatech";
  version = "5.0.1-unstable-2024-04-30";

  src = fetchFromGitHub {
    owner = "GrammaTech";
    repo = "capstone";
    rev = "30a4ecf01b43abed8527d0d84c1ea182e6e3da8b";
    hash = "sha256-JWw+S2IIBxTxDrdBlu3OqiMZ13y0T1bC2jpUDC3Mn5M=";
  };

  preConfigure = ''
    substituteInPlace capstone.pc.in \
      --replace \''${prefix}/@CMAKE_INSTALL_LIBDIR@ @CMAKE_INSTALL_FULL_LIBDIR@
  '';
}

