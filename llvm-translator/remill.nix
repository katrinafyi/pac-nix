{ lib
, stdenv
, fetchFromGitHub
, python3
, cmake
, ninja
, llvmPackages
, xed
, glog
, gtest
, sleigh
, breakpointHook
, git-am-shim
, abseil-cpp
}:
with llvmPackages;
let
clang = llvmPackages.libcxxClang;
  # cxx-all = fetchurl {
  #   url = "https://github.com/lifting-bits/cxx-common/releases/download/v0.6.4/vcpkg_ubuntu-22.04_llvm-16_amd64.tar.xz";
  #   hash = "sha256-RiGiHgU4XfC9hZ/bVbBBEHTztSU6OOUAz6VZBXIVpxg=";
  # };

  # cxx-common = runCommand "cxx-common-reduced" {} 
  # ''
  #   mkdir $out
  #   cd $out
  #   XZ_OPT='-T0' tar xf ${cxx-all} --strip-components=1
  #   rm -rf installed/*/{tools,share,include}/{llvm,clang,mlir} installed/*/lib/lib{clang,LLVM,MLIR,mlir,LTO}*
  # '';

  cxx-common = fetchFromGitHub {
    owner = "lifting-bits";
    repo = "cxx-common";
    rev = "v0.6.4";
    hash = "";

    postFetch = ''
      substituteInPlace ports/xed/XEDConfig.cmake \
        --replace "''${ROOT}" '${xed}'
    '';
  };

  remill-src = fetchFromGitHub {
    owner = "lifting-bits";
    repo = "remill";
    rev = "391261923a036196ad9dd2c8213c0193ad727cd9";
    hash = "sha256-DiskkPngmnq4adR5ew2h1vFvD7y3MWdoo0AcNv+OaAU=";
  };

  sleigh' = sleigh.overrideAttrs {
    sleigh_ADDITIONAL_PATCHES = [
      "${remill-src}/patches/sleigh/0001-AARCH64base.patch"
      "${remill-src}/patches/sleigh/0001-AARCH64instructions.patch"
      "${remill-src}/patches/sleigh/0001-ARM.patch"
      "${remill-src}/patches/sleigh/0001-ARMTHUMBinstructions.patch"
      "${remill-src}/patches/sleigh/0001-ppc_common.patch"
      "${remill-src}/patches/sleigh/0001-ppc_instructions.patch"
      "${remill-src}/patches/sleigh/0001-ppc_isa.patch"
      "${remill-src}/patches/sleigh/0001-ppc_vle.patch"
      "${remill-src}/patches/sleigh/0001-quicciii.patch"
      "${remill-src}/patches/sleigh/x86-ia.patch"
    ];
  };

  ghidra-fork = fetchFromGitHub {
    owner = "trail-of-forks";
    repo = "ghidra";
    rev = "e7196d8b943519d3aa5eace6a988cda3aa6aca5c";
    hash = "sha256-uOaTY9dYVAyu5eU2tLKNJWRwN98OQkCVynwQvjeBQB8=";
  };
in
stdenv.mkDerivation (self: {
  pname = "remill";
  version = "unstable";

  src = remill-src;

  nativeBuildInputs = [ python3 cmake clang breakpointHook ];
  buildInputs = [ sleigh' llvm xed glog gtest abseil-cpp ];

  # cmakeXED = ''
  #   include(${cxx-common}/ports/xed/XEDConfig.cmake)
  # '';

  # NIX_DEBUG = 1;

  preConfigure = ''
    ghidra=$(mktemp -d)
    cp -r --no-preserve=mode ${ghidra-fork}/. $ghidra

    substituteInPlace CMakeLists.txt \
      --replace 'FetchContent_Declare(sleigh' 'find_package(sleigh REQUIRED COMPONENTS Support) ${"\n"} message(STATUS "ignore FetchContent(Sleigh "' \
      --replace 'FetchContent_MakeAvailable(sleigh)' ""

    substituteInPlace CMakeLists.txt \
      --replace 'GIT_REPOSITORY https://github.com/trail-of-forks/ghidra.git' "SOURCE_DIR $ghidra"

    substituteInPlace CMakeLists.txt \
      --replace 'XED::XED' xed \
      --replace 'find_package(XED CONFIG REQUIRED)' "" \
      --replace 'find_package(Z3 CONFIG REQUIRED)' "" \
      --replace 'InstallExternalTarget(' 'message(STATUS ' \


    substituteInPlace CMakeLists.txt \
      --replace "sleigh_compile(" "set(sleigh_BINARY_DIR $out) ${"\n"} sleigh_compile("

    cp -v $(command -v clang++) .
    substituteInPlace ./clang++ --replace 'cInclude=1' cInclude=0

    platform=${lib.replaceStrings ["-" "."] ["_" "_"] stdenv.targetPlatform.config}
    LIBCXX=$(
      source ${clang}/nix-support/utils.bash; 
      source ${clang}/nix-support/add-flags.sh; 
      eval 'echo $NIX_CFLAGS_COMPILE_'$platform ' $NIX_CXXSTDLIB_COMPILE_'$platform)

    substituteInPlace cmake/BCCompiler.cmake \
      --replace 'find_package(Clang CONFIG REQUIRED)' "" \
      --replace 'get_target_property(CLANG_PATH clang LOCATION)' "" \
      --replace 'get_target_property(LLVMLINK_PATH llvm-link LOCATION)' "" \
      --replace '$'{CLANG_PATH} $(pwd)/clang++ \
      --replace '$'{LLVMLINK_PATH} $(command -v llvm-link) \
      --replace '$'{include_directory_list} '$'{include_directory_list}" -include cstdlib"

    # failing due to "no thread api" and incorrectly including glibc

    export CXXFLAGS='-include cstdint -include cstdlib'

    substituteInPlace lib/Arch/*/Runtime/CMakeLists.txt \
      --replace 'c++17' 'c++20'
  '';

  cmakeFlags = [
    "-DCMAKE_VERBOSE_MAKEFILE=True"
    # "-DCMAKE_TOOLCHAIN_FILE=${cxx-common}/scripts/buildsystems/vcpkg.cmake"
    # "-DCMAKE_PREFIX_PATH=${cxx-common}/installed/x64-linux-rel"
    "-DDVCPKG_TARGET_TRIPLET=x64-linux-rel"
    "-DGIT_EXECUTABLE=${git-am-shim}"
    "-DCMAKE_VERBOSE_MAKEFILE=True"
    "-DFETCHCONTENT_QUIET=OFF"

    # "-DCMAKE_BC_COMPILER=${llvmPackages.libcxxClang}/bin/clang"
    # "-DCMAKE_BC_LINKER=${llvmPackages.llvm}/bin/llvm-link"
    # "-DCLANG_PATH=${llvmPackages.libcxxClang}/bin/clang"
  ];

})
