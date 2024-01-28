{ lib
, stdenv
, fetchFromGitHub
, llvmPackages
, cmake
, xed
, glog
, gtest
, sleigh
, abseil-cpp
, glibc_multi
, git-am-shim
, git
, writeShellScript
}:
let
  clang = llvmPackages.libcxxClang;
  llvm = llvmPackages.llvm;

  shim-shim = writeShellScript "git-shim-shim" 
  ''
    if [[ $1 == show ]] || [[ $1 == describe ]]; then
      exec ${git}/bin/git "$@"
    else
      exec ${git-am-shim} "$@"
    fi
  '';

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

  remill-src = fetchFromGitHub {
    owner = "lifting-bits";
    repo = "remill";
    # sparc working but llvm 17: 391261923a036196ad9dd2c8213c0193ad727cd9
    rev = "7182636a687e5e005e3336108a653de3aec0362b";
    hash = "sha256-2PXg/Wbgmo49aK4MO9T5+vLkLuYiaHpNb0DbuCn4P80=";
    leaveDotGit = true;
  };
in
stdenv.mkDerivation (self: {
  pname = "remill";
  version = "unstable-2023-09-27";

  src = remill-src;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ sleigh' llvm xed glog gtest abseil-cpp glibc_multi ];

  outputs = [ "out" "dev" "lib" ];

  preConfigure = ''
    function check-version() {
      repo="$1"; nixhash="$2"
      expected_ghidra=$(grep "FetchContent_Declare($repo" --after-context=3 CMakeLists.txt | grep GIT_TAG | xargs echo | cut -d' ' -f2)
      if ! (set -x; echo "nix $repo: $nixhash" | grep -q " $expected_ghidra"); then
        echo "ERROR: mismatched $repo rev."
        return 1
      fi
    }
    check-version ghidra-fork ${ghidra-fork.rev}
    check-version sleigh ${sleigh.src.rev}

    ghidra=$(mktemp -d)
    cp -r --no-preserve=mode ${ghidra-fork}/. $ghidra

    substituteInPlace CMakeLists.txt \
      --replace 'GIT_REPOSITORY https://github.com/trail-of-forks/ghidra.git' "SOURCE_DIR $ghidra"

    substituteInPlace CMakeLists.txt \
      --replace "sleigh_compile(" "set(sleigh_BINARY_DIR $(mktemp -d)) ${"\n"} sleigh_compile("
    
    # these dependencies found via buildInputs
    substituteInPlace CMakeLists.txt \
      --replace 'XED::XED' xed \
      --replace 'find_package(XED CONFIG REQUIRED)' "" \
      --replace 'find_package(Z3 CONFIG REQUIRED)' "" \
      --replace 'InstallExternalTarget(' 'message(STATUS ' \

    # sleigh also found via buildInputs
    substituteInPlace CMakeLists.txt \
      --replace 'FetchContent_Declare(sleigh' 'find_package(sleigh REQUIRED COMPONENTS Support) ${"\n"} message(STATUS "ignore FetchContent(Sleigh "' \
      --replace 'FetchContent_MakeAvailable(sleigh)' ""

    BC_CXX=${clang}/bin/clang++
    BC_CXXFLAGS="-g0 $(cat ${clang}/nix-support/libcxx-cxxflags) -D_LIBCPP_HAS_NO_THREADS"
    BC_LD=$(command -v llvm-link)
    BC_LDFLAGS=""

    # manually specify bc compiler. nix's libclang, which provides clangconfig.cmake, is missing the wrapper.
    substituteInPlace cmake/BCCompiler.cmake \
      --replace 'find_package(Clang CONFIG REQUIRED)' "" \
      --replace 'get_target_property(CLANG_PATH clang LOCATION)' "" \
      --replace 'get_target_property(LLVMLINK_PATH llvm-link LOCATION)' "" \
      --replace '$'{CLANG_PATH} $BC_CXX \
      --replace '$'{LLVMLINK_PATH} $BC_LD \
      --replace '$'{source_file_option_list} '$'{source_file_option_list}" $BC_CXXFLAGS" \
      --replace '$'{linker_flag_list} '$'{linker_flag_list}" $BC_LDFLAGS"
  '';

  CXXFLAGS = "-include cstdint -g0";

  cmakeFlags = [
    # "-DCMAKE_VERBOSE_MAKEFILE=True"
    "-DDVCPKG_TARGET_TRIPLET=x64-linux-rel"
    "-DGIT_EXECUTABLE=${shim-shim}"
    # "-DFETCHCONTENT_QUIET=OFF"
    "-DREMILL_BUILD_SPARC32_RUNTIME=False"
  ];

})
