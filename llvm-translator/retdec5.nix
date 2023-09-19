{ stdenv
, fetchFromGitHub
, fetchpatch
, fetchzip
, lib
, callPackage
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
, time
, upx
, ncurses
, libffi
, libxml2
, zlib
, withPEPatterns ? false
}:

let
  capstone = fetchFromGitHub {
    owner = "capstone-engine";
    repo = "capstone";
    rev = "5.0-rc2";
    sha256 = "sha256-nB7FcgisBa8rRDS3k31BbkYB+tdqA6Qyj9hqCnFW+ME=";
  };
  elfio = fetchFromGitHub {
    owner = "avast-tl";
    repo = "elfio";
    rev = "998374baace397ea98f3b1d768e81c978b4fba41";
    sha256 = "09n34rdp0wpm8zy30zx40wkkc4gbv2k3cv181y6c1260rllwk5d1";
  };
  keystone = fetchFromGitHub { # only for tests
    owner = "keystone-engine";
    repo = "keystone";
    rev = "d7ba8e378e5284e6384fc9ecd660ed5f6532e922";
    sha256 = "1yzw3v8xvxh1rysh97y0i8y9svzbglx2zbsqjhrfx18vngh0x58f";
  };
  libdwarf = fetchFromGitHub {
    owner = "avast-tl";
    repo = "libdwarf";
    rev = "85465d5e235cc2d2f90d04016d6aca1a452d0e73";
    sha256 = "11y62r65py8yp57i57a4cymxispimn62by9z4j2g19hngrpsgbki";
  };
  llvm = fetchFromGitHub {
    owner = "avast-tl";
    repo = "llvm";
    rev = "2a1f3d8a97241c6e91710be8f84cf3cf80c03390";
    sha256 = "sha256-+v1T0VI9R92ed9ViqsfYZMJtPCjPHCr4FenoYdLuFOU=";
  };
  pelib = fetchFromGitHub {
    owner = "avast-tl";
    repo = "pelib";
    rev = "a7004b2e80e4f6dc984f78b821e7b585a586050d";
    sha256 = "0nyrb3g749lxgcymz1j584xbb1x6rvy1mc700lyn0brznvqsm81n";
  };
  rapidjson = fetchFromGitHub {
    owner = "Tencent";
    repo = "rapidjson";
    rev = "v1.1.0";
    sha256 = "1jixgb8w97l9gdh3inihz7avz7i770gy2j2irvvlyrq3wi41f5ab";
  };
  # yaracpp = callPackage ./yaracpp.nix {}; # is its own package because it needs a patch
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
  jsoncpp = fetchFromGitHub {
    owner = "open-source-parsers";
    repo = "jsoncpp";
    rev = "1.8.4";
    sha256 = "1z0gj7a6jypkijmpknis04qybs1hkd04d1arr3gy89lnxmp6qzlm";
  };
  googletest = fetchFromGitHub { # only for tests
    owner = "google";
    repo = "googletest";
    rev = "90a443f9c2437ca8a682a1ac625eba64e1d74a8a";
    sha256 = "sha256-fmqPMbUZTciaU61GUp1xR7ZGRSLz8nM+EYZaRKp0ryk=";
  };
  tinyxml2 = fetchFromGitHub {
    owner = "leethomason";
    repo = "tinyxml2";
    rev = "cc1745b552dd12bb1297a99f82044f83b06729e0";
    sha256 = "015g8520a0c55gwmv7pfdsgfz2rpdmh3d1nq5n9bd65n35492s3q";
  };

  retdec-support = let
    version = "2019-03-08"; # make sure to adjust both hashes (once with withPEPatterns=true and once withPEPatterns=false)
  in fetchzip {
    url = "https://github.com/avast-tl/retdec-support/releases/download/${version}/retdec-support_${version}.tar.xz";
    hash = if withPEPatterns then ""
                             else "sha256-paeNrxXTE7swuKjP+sN42xnCYS7x5Y5CcUe7tyzsLxs=";
    stripRoot = false;
    # Removing PE signatures reduces this from 3.8GB -> 642MB (uncompressed)
    postFetch = lib.optionalString (!withPEPatterns) ''
      rm -r "$out/generic/yara_patterns/static-code/pe"
    '';
  } // {
    inherit version; # necessary to check the version against the expected version
    rev = version;
  };

  # patch CMakeLists.txt for a dependency and compare the versions to the ones expected by upstream
  # this has to be applied for every dependency (which it is in postPatch)
  patchDep = dep: ''
    # check if our version of dep is the same version that upstream expects
    echo "Checking version of ${dep.dep_name}"
    expected_rev="$( grep -A1 ${lib.toUpper dep.dep_name}${dep.dep_key or "_URL"} cmake/deps.cmake | 
                      tail -n1 | tr -d '[:blank:]"' |
                      sed s/\.zip$//g | grep -oE '[^/]+$')"

    if [ "$expected_rev" != '${dep.rev}' ]; then
      echo "The ${dep.dep_name} dependency has the wrong version: ${dep.rev} while $expected_rev is expected."
      exit 1
    fi
  '';

in stdenv.mkDerivation rec {
  pname = "retdec";

  # If you update this you will also need to adjust the versions of the updated dependencies. You can do this by first just updating retdec
  # itself and trying to build it. The build should fail and tell you which dependencies you have to upgrade to which versions.
  # I've notified upstream about this problem here:
  # https://github.com/avast-tl/retdec/issues/412
  # gcc is pinned to gcc8 in all-packages.nix. That should probably be re-evaluated on update.
  version = "5.0";

  src = fetchFromGitHub {
    owner = "avast";
    repo = pname;
    rev = "refs/tags/v${version}";
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
  ];

  cmakeFlags_deps = builtins.map 
    (dep: "-D${lib.toUpper dep.dep_name}_URL=${dep}")
    external_deps;

  cmakeFlags = cmakeFlags_deps ++ [
    "-DRETDEC_TESTS=${if doInstallCheck then "ON" else "OFF"}" # build tests
  ];

  # all dependencies that are normally fetched during build time (the subdirectories of `deps`)
  # all of these need to be fetched through nix and the CMakeLists files need to be patched not to fetch them themselves
  external_deps = [
    (capstone // { dep_name = "capstone"; })
    # (elfio // { dep_name = "elfio"; })
    (googletest // { dep_name = "googletest"; })
    # (jsoncpp // { dep_name = "jsoncpp"; })
    (keystone // { dep_name = "keystone"; })
    # (libdwarf // { dep_name = "libdwarf"; })
    (llvm // { dep_name = "llvm"; })
    # (pelib // { dep_name = "pelib"; })
    # (rapidjson // { dep_name = "rapidjson"; })
    # (tinyxml2 // { dep_name = "tinyxml2"; })
    (yaracpp // { dep_name = "yara"; })
    (yaramod // { dep_name = "yaramod"; })
    (retdec-support // { dep_name = "support_pkg"; dep_key = "_VERSION"; })
  ];

  patches = [];

  postPatch = (lib.concatMapStrings patchDep external_deps) + ''

    mkdir -p "$out/share/retdec"
    cp -r ${retdec-support} "$out/share/retdec/support" # write permission needed during install
    chmod -R u+w "$out/share/retdec/support"

    # python file originally responsible for fetching the retdec-support archive to $out/share/retdec
    # that is not necessary anymore, so empty the file
    echo > support/install-share.py

    cat <<EOF >> deps/yara/CMakeLists.txt
ExternalProject_Add_Step(yara chmod
	WORKING_DIRECTORY ''${YARA_DIR}
	DEPENDEES download
	COMMAND chmod -R u+rw .
)
EOF

    # the CMakeLists assumes CMAKE_INSTALL_BINDIR, etc are path components but in Nix, they are absolute.
    # therefore, we need to remove the unnecessary CMAKE_INSTALL_PREFIX prepend.
    substituteInPlace ./CMakeLists.txt \
      --replace "''$"{CMAKE_INSTALL_PREFIX}/"''$"{RETDEC_INSTALL_BIN_DIR} "''$"{CMAKE_INSTALL_FULL_BINDIR} \
      --replace "''$"{CMAKE_INSTALL_PREFIX}/"''$"{RETDEC_INSTALL_LIB_DIR} "''$"{CMAKE_INSTALL_FULL_LIBDIR} \
      --replace "''$"{CMAKE_INSTALL_PREFIX}/"''$"{RETDEC_INSTALL_SUPPORT_DIR} "''$"{RETDEC_INSTALL_SUPPORT_DIR} \

    # similarly for yaramod. here, we fix the LIBDIR to lib64.
    substituteInPlace deps/yaramod/CMakeLists.txt \
      --replace "''$"{YARAMOD_INSTALL_DIR}/"''$"{CMAKE_INSTALL_LIBDIR} "''$"{YARAMOD_INSTALL_DIR}/lib64 \
      --replace CMAKE_ARGS 'CMAKE_ARGS -DCMAKE_INSTALL_LIBDIR=lib64'
  '';

  doInstallCheck = false;
  installCheckPhase = ''
    ${python3.interpreter} "$out/bin/retdec-tests-runner.py"

    rm -rf $out/bin/__pycache__
  '';

  meta = with lib; {
    description = "A retargetable machine-code decompiler based on LLVM";
    homepage = "https://retdec.com";
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill timokau ];
    platforms = ["x86_64-linux" "i686-linux"];
  };
}
