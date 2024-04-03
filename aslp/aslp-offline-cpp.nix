{ lib
, stdenv
, runCommand
, nix-gitignore
, fetchFromGitHub 
, aslp
, cmake
, llvmPackages
}:

let
  aslp-cpp-backend = aslp.overrideAttrs {
    # src = fetchFromGitHub {
    #   owner = "UQ-PAC";
    #   repo = "aslp";
    #   rev = "75f506d577c60f89275af37bf22cefb095ec7a81";
    #   hash = "sha256-Di1EFdpNJz7cJgTHO/4dLishmB2Ptlm4WpyYW/0VmNY=";
    # };
    src = nix-gitignore.gitignoreSource [] /home/rina/progs/aslp;
  };

  src = runCommand "aslp-offline-cpp-src" {} ''
    mkdir -p $out
    cp -r --no-preserve=mode ${aslp-cpp-backend.src}/offlineASL-cpp/. $out
    echo ":gen A64 .+ cpp $out" | ${lib.getExe aslp-cpp-backend}
  '';

in stdenv.mkDerivation {
  pname = "aslp-offline-cpp";
  version = aslp-cpp-backend.version;

  src = src;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ llvmPackages.libllvm ];

  env.CXXFLAGS = "-Os";
  hardeningDisable = [ "all" ]; # simply too slow.
}
