{ lib
, stdenv
, clangStdenv
, runCommand
, nix-gitignore
, fetchFromGitHub 
, aslp
, cmake
, meson
, ninja
, llvmPackages
}:

let
  aslp-cpp-backend = aslp.overrideAttrs (prev: {
    # src = fetchFromGitHub {
    #   owner = "UQ-PAC";
    #   repo = "aslp";
    #   rev = "75f506d577c60f89275af37bf22cefb095ec7a81";
    #   hash = "sha256-Di1EFdpNJz7cJgTHO/4dLishmB2Ptlm4WpyYW/0VmNY=";
    # };
    src = nix-gitignore.gitignoreSource [] /home/rina/progs/aslp;
    doCheck = false;
    env = prev.env // { ANTLR4_JAR_LOCATION = "/nowhere"; };
  });

  src = runCommand "aslp-offline-cpp-src" {} ''
    mkdir -p $out
    cp -r --no-preserve=mode ${aslp-cpp-backend.src}/offlineASL-cpp/. $out
    echo ":gen A64 .+ cpp $out" | ${lib.getExe aslp-cpp-backend}
  '';

in clangStdenv.mkDerivation {
  pname = "aslp-offline-cpp";
  version = aslp-cpp-backend.version;

  src = src;

  mesonBuildType = "debug";
  nativeBuildInputs = [ meson ninja ];
  buildInputs = [ llvmPackages.libllvm ];
}
