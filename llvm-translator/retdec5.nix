{ stdenv
, fetchFromGitHub
, fetchzip
, fetchpatch
, lib
, openssl
, cmake
, autoconf
, automake
, libtool
, pkg-config
, bison
, flex
, capstone
, gtest
, groff
, perl
, python3
, ncurses
, libffi
, libxml2
, yara
, zlib
, fmt
, re2
, breakpointHook
, keystone
, nlohmann_json
, file
, jansson
}:

let
  yara' = (yara.override { enableStatic = true; }).overrideAttrs { propagatedBuildInputs = [ openssl file jansson ]; };
  keystone' = keystone.overrideAttrs (p: { cmakeFlags = p.cmakeFlags ++ [ "-DBUILD_SHARED_LIBS=OFF" ]; });
  capstone' = capstone.overrideAttrs {
    # must be earlier than this commit which renamed registers: https://github.com/capstone-engine/capstone/commit/d090c76703a0884076b2a1c25a4b11c77ab0f822
    version = "5.0-rc2";
    src = fetchFromGitHub {
      owner = "capstone-engine";
      repo = "capstone";
      rev = "5.0-rc2";
      sha256 = "sha256-nB7FcgisBa8rRDS3k31BbkYB+tdqA6Qyj9hqCnFW+ME=";
    };
    patches = [
      # these 3 patches fix the pkg-config file for nix.
      (fetchpatch {
        url = "https://github.com/capstone-engine/capstone/commit/ac1d85e88bfc9a476fb207613d5695d9b629eeb3.patch";
        hash = "sha256-K3b2tRHmnfPCv2Ebq8WHcy89536jpfTGd0l4lNHPP48=";
      })
      (fetchpatch {
        url = "https://github.com/capstone-engine/capstone/commit/c703d968d1dbf5e557901cee4eadd7731c1a4747.patch";
        hash = "sha256-65xPXKv0apL5TFGiUnS/lcKX3mz7Yne1W/kLX252fCU=";
      })
      (fetchpatch {
        url = "https://github.com/capstone-engine/capstone/commit/8479233b6499b15e2aaf49f2364caa193f759f07.patch";
        hash = "sha256-D31XUvYMkJGVDV32AyQx1CSP9O4rTDXtJWjNu5PVOUg=";
      })
    ];
  };
  yaramod = stdenv.mkDerivation {
    pname = "yaramod";
    version = "3.21.0";
    src = fetchFromGitHub {
      owner = "avast";
      repo = "yaramod";
      rev = "v3.21.0";
      sha256 = "sha256-YkMDoFwWPrDhAgDnPpNCU1NlnAPhwYQF/KFaRFn+juQ=";
    };
    nativeBuildInputs = [ cmake python3 ];
    propagatedBuildInputs = [ fmt re2 nlohmann_json ];
    CXXFLAGS = [ "-Wno-pessimizing-move" ];
    dontDisableStatic = true;
    cmakeFlags = [ "-DPOG_BUNDLED_FMT=OFF" "-DPOG_BUNDLED_RE2=OFF" ];
    preConfigure = ''
      # permit using non-bundled fmt and re2
      substituteInPlace deps/CMakeLists.txt --replace 'FORCE' ""

      substituteInPlace src/CMakeLists.txt deps/{json,pog,pog/deps/fmt,pog/deps/re2}/CMakeLists.txt \
        --replace '$'{CMAKE_INSTALL_PREFIX}/'$'{CMAKE_INSTALL_LIBDIR} '$'{CMAKE_INSTALL_LIBDIR} \
        --replace '$'{CMAKE_INSTALL_PREFIX}/'$'{CMAKE_INSTALL_INCLUDEDIR} '$'{CMAKE_INSTALL_INCLUDEDIR} \
        --replace '$'{CMAKE_INSTALL_PREFIX}/'$'{CMAKE_INSTALL_DATADIR} '$'{CMAKE_INSTALL_DATADIR}
    '';
  };
  llvm' = stdenv.mkDerivation {
    pname = "llvm-avast";
    version = "8.0.0";
    cmakeFlags = [ "-DLLVM_TARGETS_TO_BUILD=X86" "-DLLVM_REQUIRES_RTTI=YES" "-DLLVM_ENABLE_WARNINGS=NO" "-DLLVM_ENABLE_RTTI=ON" "-DLLVM_ENABLE_EH=ON" "-DLLVM_INCLUDE_TOOLS=OFF" "-DLLVM_INCLUDE_UTILS=OFF" "-DLLVM_INCLUDE_RUNTIMES=OFF" "-DLLVM_INCLUDE_EXAMPLES=OFF" "-DLLVM_INCLUDE_TESTS=OFF" "-DLLVM_INCLUDE_GO_TESTS=OFF" "-DLLVM_INCLUDE_BENCHMARKS=OFF" "-DLLVM_INCLUDE_DOCS=OFF" "-DLLVM_BUILD_TOOLS=OFF" "-DLLVM_BUILD_UTILS=OFF" "-DLLVM_BUILD_RUNTIMES=OFF" "-DLLVM_BUILD_RUNTIME=OFF" "-DLLVM_BUILD_EXAMPLES=OFF" "-DLLVM_BUILD_TESTS=OFF" "-DLLVM_BUILD_BENCHMARKS=OFF" "-DLLVM_BUILD_DOCS=OFF" "-DLLVM_ENABLE_BINDINGS=OFF" "-DLLVM_ENABLE_TERMINFO=OFF" ];
    nativeBuildInputs = [ cmake python3 ];
    src = fetchFromGitHub {
      owner = "avast-tl";
      repo = "llvm";
      rev = "2a1f3d8a97241c6e91710be8f84cf3cf80c03390";
      sha256 = "sha256-+v1T0VI9R92ed9ViqsfYZMJtPCjPHCr4FenoYdLuFOU=";
    };
  };

  retdec-support-version = "2019-03-08";
  retdec-support =
    { rev = retdec-support-version; } // # for checking the version against the expected version
    fetchzip {
      url = "https://github.com/avast-tl/retdec-support/releases/download/${retdec-support-version}/retdec-support_${retdec-support-version}.tar.xz";
      hash = "sha256-paeNrxXTE7swuKjP+sN42xnCYS7x5Y5CcUe7tyzsLxs=";
    };

  function-substitute-dep = 
  ''
    function substitute-dep() {
      file="''${1?}"; pname="''${2?}"
      shift 2

      sed -i 's/ExternalProject_[^(]\+[(]/set(IGNORED /g' "$file"
      old="$(cat $file)"

      echo "$pname" > "$file"
      echo "$old" >> "$file"

      if [[ -n "$@" ]]; then
        substituteInPlace "$file" "$@"
      fi
    }
    '';

in
stdenv.mkDerivation (self: {
  pname = "retdec";

  # If you update this you will also need to adjust the versions of the updated dependencies. You can do this by first just updating retdec
  # itself and trying to build it. The build should fail and tell you which dependencies you have to upgrade to which versions.
  # I've notified upstream about this problem here:
  # https://github.com/avast-tl/retdec/issues/412
  # gcc is pinned to gcc8 in all-packages.nix. That should probably be re-evaluated on update.
  version = "5.0";

  src = fetchFromGitHub {
    owner = "avast";
    repo = "retdec";
    rev = "refs/tags/v${self.version}";
    sha256 = "sha256-H4e+aSgdBBbG6X6DzHGiDEIASPwBVNVsfHyeBTQLAKI=";
  };

  nativeBuildInputs = [
    breakpointHook
    # ninja
    cmake
    autoconf
    automake
    libtool
    pkg-config
    bison
    flex
    groff
    perl
    python3
  ];

  buildInputs = [
    capstone'
    llvm'
    yara'
    yaramod
    keystone'
    gtest
    ncurses
    libffi
    libxml2
    zlib
  ];


  cmakeFlags = [
    "-DRETDEC_TESTS=${if self.doInstallCheck then "ON" else "OFF"}" # build tests
    "-DRETDEC_USE_SYSTEM_CAPSTONE=ON"
  ];

  patches = [ ];

  preConfigure =
    function-substitute-dep
    +
    ''
      mkdir -p "$out/share/retdec"
      cp -r ${retdec-support} "$out/share/retdec/support" # write permission needed during install
      chmod -R u+w "$out/share/retdec/support"

      # the CMakeLists assumes CMAKE_INSTALL_BINDIR, etc are path components but in Nix, they are absolute.
      # therefore, we need to remove the unnecessary CMAKE_INSTALL_PREFIX prepend.
      substituteInPlace ./CMakeLists.txt \
        --replace "''$"{CMAKE_INSTALL_PREFIX}/"''$"{RETDEC_INSTALL_BIN_DIR} "''$"{CMAKE_INSTALL_FULL_BINDIR} \
        --replace "''$"{CMAKE_INSTALL_PREFIX}/"''$"{RETDEC_INSTALL_LIB_DIR} "''$"{CMAKE_INSTALL_FULL_LIBDIR} \
        --replace "''$"{CMAKE_INSTALL_PREFIX}/"''$"{RETDEC_INSTALL_SUPPORT_DIR} "''$"{RETDEC_INSTALL_SUPPORT_DIR} \

      substitute-dep deps/googletest/CMakeLists.txt 'find_package(GTest REQUIRED)' \
          --replace '$'{GTEST_LIB} "GTest::gtest" \
          --replace '$'{GMOCK_LIB} "GTest::gmock" \
          --replace '$'{GTEST_MAIN_LIB} "GTest::gtest_main" \
          --replace '$'{GMOCK_MAIN_LIB} "GTest::gmock_main"

      substitute-dep deps/llvm/CMakeLists.txt 'find_package(LLVM REQUIRED)' \
          --replace '$'{LLVM_INSTALL_DIR}/include '$'{LLVM_INCLUDE_DIRS} \
          --replace '$'{LLVM_INSTALL_DIR}/lib '$'{LLVM_LIBRARY_DIRS} \
          --replace '$'{source_dir}/include ${llvm'.src}/include  # retdec accesses llvm implementation details...

      substitute-dep deps/yara/CMakeLists.txt \
        'find_package(PkgConfig) ${"\n"} pkg_check_modules(YARA REQUIRED IMPORTED_TARGET yara)' \
        --replace '$'{YARA_LIB} '$'{YARA_LINK_LIBRARIES} \
        --replace '$'{YARA_INCLUDE_DIR} '$'{YARA_INCLUDE_DIRS} \
        --replace '$'{YARAC_PATH} ${lib.getBin yara'}/bin/yarac

      # yaramod does not export .pc or .cmake so we need to specify this manually
      substitute-dep deps/yaramod/CMakeLists.txt "find_package(fmt REQUIRED) ${"\n"} find_package(re2 REQUIRED)" \
        --replace '$'{YARAMOD_INSTALL_DIR} ${lib.getLib yaramod} \
        --replace '$'{CMAKE_INSTALL_LIBDIR} lib \
        --replace '$<BUILD_INTERFACE:''${RE2_LIB}>' "re2::re2" \
        --replace '$<BUILD_INTERFACE:''${FMT_LIB}>' "fmt::fmt"

      substitute-dep deps/keystone/CMakeLists.txt "find_package(PkgConfig) ${"\n"} pkg_check_modules(KEYSTONE REQUIRED IMPORTED_TARGET keystone)" \
        --replace '$'{KEYSTONE_LIB} '$'{KEYSTONE_LINK_LIBRARIES} \
        --replace '$'{KEYSTONE_INSTALL_DIR}/include '$'{KEYSTONE_INCLUDE_DIRS} \
        --replace '$'{CMAKE_INSTALL_LIBDIR} lib

      # without git, there's no chance of these passing.
      substituteInPlace tests/utils/version_tests.cpp \
        --replace VersionTests DISABLED_VersionTests
    '';

  CXXFLAGS = "-include cstdint";

  doInstallCheck = true;
  installCheckPhase = ''
    ${python3.interpreter} "$out/bin/retdec-tests-runner.py"

    rm -rf $out/bin/__pycache__
  '';

  meta = with lib; {
    description = "A retargetable machine-code decompiler based on LLVM";
    homepage = "https://retdec.com";
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill timokau ];
    platforms = [ "x86_64-linux" "i686-linux" ];
  };
})
