{ stdenv
, fetchFromGitHub
, clang17Stdenv
, cmake
}:

stdenv.mkDerivation {
  pname = "aslp-cpp";
  version = "0.1.3-unstable-2025-02-05";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "360d4e3e2da0e6801cf90f93903b40e43fd9cbfd";
    hash = "sha256-dGk1S28qdRJaQuLYhBlprV+TBlUd6XE0D+w5TGn4kls=";
  };

  prePatch = ''
    cd aslp-client-http-cpp
  '';

  patches = [ ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ];

  cmakeFlags = [ ];
}
