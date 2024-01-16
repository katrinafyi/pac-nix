{ lib
, stdenv
, fetchFromGitHub
, capstone
}:

capstone.overrideAttrs {
  pname = "capstone-grammatech";

  src = fetchFromGitHub {
    owner = "GrammaTech";
    repo = "capstone";
    rev = "a11159a0bbd680e134c53d6a16e304b53488824b";
    hash = "sha256-0aCmlXsrdWYlxqzRlXj8TNkD0s8xHMTq0YlVJ+t1fD4=";
  };

  preConfigure = ''
    substituteInPlace capstone.pc.in \
      --replace \''${prefix}/@CMAKE_INSTALL_LIBDIR@ @CMAKE_INSTALL_FULL_LIBDIR@
  '';
}

