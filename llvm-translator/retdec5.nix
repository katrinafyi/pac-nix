{ stdenv
, fetchFromGitHub
, fetchzip
, lib
, openssl
, cmake
, autoconf
, automake
, libtool
, pkg-config
, bison
, flex
, groff
, perl
, python3
, ncurses
, gtest
, libffi
, libxml2
, zlib
, enableTests ? true
}:

let
  # all dependencies that are normally fetched during build time (the subdirectories of `deps`)
  # all of these need to be fetched through nix and applied via their <NAME>_URL cmake variable
  capstone = fetchFromGitHub {
    owner = "capstone-engine";
    repo = "capstone";
    rev = "5.0-rc2";
    sha256 = "sha256-nB7FcgisBa8rRDS3k31BbkYB+tdqA6Qyj9hqCnFW+ME=";
  };
  llvm = fetchFromGitHub {
    owner = "avast-tl";
    repo = "llvm";
    rev = "2a1f3d8a97241c6e91710be8f84cf3cf80c03390";
    sha256 = "sha256-+v1T0VI9R92ed9ViqsfYZMJtPCjPHCr4FenoYdLuFOU=";
  };
  yaracpp = fetchFromGitHub {
    owner = "VirusTotal";
    repo = "yara";
    rev = "v4.2.0-rc1";
    sha256 = "sha256-WcN6ClYO2d+/MdG06RHx3kN0o0WVAY876dJiG7CwJ8w=";
  };
  yaramod = fetchFromGitHub {
    owner = "avast";
    repo = "yaramod";
    rev = "a367d910ae79698e64e99d8414695281723cd34b";
    sha256 = "sha256-mnjYQOn/Z37XAtW8YsfPewM9t1WYsyjivTnmRwYWSQ0=";
  };
  keystone = fetchFromGitHub {
    # only for tests
    owner = "keystone-engine";
    repo = "keystone";
    rev = "d7ba8e378e5284e6384fc9ecd660ed5f6532e922";
    sha256 = "1yzw3v8xvxh1rysh97y0i8y9svzbglx2zbsqjhrfx18vngh0x58f";
  };
  # googletest imported from nixpkgs

  retdec-support-version = "2019-03-08";
  retdec-support =
    { rev = retdec-support-version; } // # for checking the version against the expected version
    fetchzip {
      url = "https://github.com/avast-tl/retdec-support/releases/download/${retdec-support-version}/retdec-support_${retdec-support-version}.tar.xz";
      hash = "sha256-paeNrxXTE7swuKjP+sN42xnCYS7x5Y5CcUe7tyzsLxs=";
    };

  check-dep = name: dep:
    ''
      context="$(grep ${name}_URL --after-context 1 cmake/deps.cmake)"
      expected="$(echo "$context" | grep --only-matching '".*"')"
      have="${dep.rev}"

      echo "checking ${name} dependency matches deps.cmake...";
      if ! echo "$expected" | grep -q "$have"; then
        printf '%s\n' "${name} version does not match!"  "  nix: $have, expected: $expected"
        false
      fi
    '';

  deps = {
    CAPSTONE = capstone;
    LLVM = llvm;
    YARA = yaracpp;
    YARAMOD = yaramod;
    SUPPORT_PKG = retdec-support;
  } // lib.optionalAttrs enableTests {
    KEYSTONE = keystone;
  };
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
    openssl
    ncurses
    libffi
    libxml2
    zlib
  ] ++ lib.optional self.doInstallCheck gtest;

  cmakeFlags = [
    "-DRETDEC_TESTS=${if self.doInstallCheck then "ON" else "OFF"}" # build tests
  ] ++ lib.mapAttrsToList (k: v: "-D${k}_URL=${v}") deps;

  patches = [ ];

  # fix for a gcc13 change.
  env.CXXFLAGS = "-include cstdint";

  preConfigure =
    lib.concatStringsSep "\n" (lib.mapAttrsToList check-dep deps)
    +
    ''
            mkdir -p "$out/share/retdec"
            cp --no-preserve=mode -r ${retdec-support} "$out/share/retdec/support" # write permission needed during install

            # the CMakeLists assume CMAKE_INSTALL_BINDIR, etc are path components but in Nix, they are absolute.
            # therefore, we need to remove the unnecessary CMAKE_INSTALL_PREFIX prepend.
            substituteInPlace ./CMakeLists.txt \
              --replace "''$"{CMAKE_INSTALL_PREFIX}/"''$"{RETDEC_INSTALL_BIN_DIR} "''$"{CMAKE_INSTALL_FULL_BINDIR} \
              --replace "''$"{CMAKE_INSTALL_PREFIX}/"''$"{RETDEC_INSTALL_LIB_DIR} "''$"{CMAKE_INSTALL_FULL_LIBDIR} \
              --replace "''$"{CMAKE_INSTALL_PREFIX}/"''$"{RETDEC_INSTALL_SUPPORT_DIR} "''$"{RETDEC_INSTALL_SUPPORT_DIR} \

            # similarly for yaramod. here, we fix the LIBDIR to lib64. for whatever reason, only "lib64" works.
            substituteInPlace deps/yaramod/CMakeLists.txt \
              --replace "''$"{YARAMOD_INSTALL_DIR}/"''$"{CMAKE_INSTALL_LIBDIR} "''$"{YARAMOD_INSTALL_DIR}/lib64 \
              --replace CMAKE_ARGS 'CMAKE_ARGS -DCMAKE_INSTALL_LIBDIR=lib64'

            # yara needs write permissions in the generated source directory.
            echo ${lib.escapeShellArg ''
              ExternalProject_Add_Step(
                yara chmod WORKING_DIRECTORY ''${YARA_DIR}
      	        DEPENDEES download COMMAND chmod -R u+rw .
              )
            ''} >> deps/yara/CMakeLists.txt

            # patch gtest to use the system package
            gtest=deps/googletest/CMakeLists.txt
            old="$(cat $gtest)"
            (echo 'find_package(GTest REQUIRED)'; echo "$old") > $gtest
            sed -i 's/ExternalProject_[^(]\+[(]/ set(IGNORED /g' $gtest

            substituteInPlace $gtest \
              --replace '$'{GTEST_LIB} "GTest::gtest"\
              --replace '$'{GMOCK_LIB} "GTest::gmock"\
              --replace '$'{GTEST_MAIN_LIB} "GTest::gtest_main"\
              --replace '$'{GMOCK_MAIN_LIB} "GTest::gmock_main"

            # without git history, there's no chance of these tests passing.
            substituteInPlace tests/utils/version_tests.cpp \
              --replace VersionTests DISABLED_VersionTests
    '';

  doInstallCheck = enableTests;
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
