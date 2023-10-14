{ stdenv,
  fetchzip,
  fetchurl,
  fetchFromGitHub, 
  symlinkJoin,
  python3,
  bash,
  cmake,
  ninja,
  git,
}:

let 
  cxx-common = fetchzip {
    url = "https://github.com/lifting-bits/cxx-common/releases/download/v0.2.7/vcpkg_ubuntu-20.04_llvm-14_amd64.tar.xz";
    hash = "sha256-FTw/GFLasAM5rKvgbltLNwJ8464x2O5I2TZMtuMSrVo=";
  };

  ghidra = fetchFromGitHub {
    owner = "NationalSecurityAgency";
    repo = "ghidra";
    rev = "Ghidra_10.1.4_build";
    leaveDotGit = true;
    hash = "sha256-8W2uK7F/B8a2MALtGIq1/QiTJeynDod5xHpR4qU6p9g=";
  };

  sleigh = fetchFromGitHub {
    owner = "lifting-bits";
    repo = "sleigh";
    rev = "5ee2f2c16250a6529108e6a6fff89e0f147502d2";
    leaveDotGit = true;
    hash = "sha256-4p2G6kQxvkjRtWxYCaWytHhQ+UsOIeG55a4TAkEZsek=";
  };

  sleigh2 = symlinkJoin {
    name = "sleigh";
    paths = [ sleigh ];
    postBuild = ''
      CMAKE=$out/src/setup-ghidra-source.cmake
      cp --remove-destination -v $(readlink $CMAKE) $CMAKE
      # substituteInPlace $CMAKE \
      #   --replace 'GIT_REPOSITORY https://github.com/NationalSecurityAgency/ghidra' "SOURCE_DIR ${ghidra}"
    '';
  };

in stdenv.mkDerivation rec {
  pname = "remill";
  version = "v5.0.7";

  src = fetchFromGitHub {
    owner = "lifting-bits";
    repo = "remill";
    rev = "v5.0.7";
    hash = "sha256-oOEw+V5fmCoNhB9a1Y+US3Ff0M50jb9qhBKsXyUwqY4=";
    leaveDotGit = true;
  };

  nativeBuildInputs = [ python3 cmake ninja ];

  configurePhase = "true";

  buildPhase = ''
  which curl 
  exit 
    substituteInPlace scripts/build.sh \
      --replace 'source /etc/os-release' 'ID=arch' \
      --replace 'curl -LO "''${URL}"' 'true' \
      --replace 'tar -xJf "''${GITHUB_LIBS}" ''${TAR_OPTIONS}' 'mkdir -p $LIBRARY_VERSION && cp -r ${cxx-common}/. $LIBRARY_VERSION'


    ghidra=$(mktemp -d)
    cp -r ${ghidra}/. $ghidra
    echo ghidra = $ghidra

    sleigh=$(mktemp -d)
    cp -r ${sleigh}/. $sleigh
    echo sleigh = $sleigh

    cat $sleigh/src/setup-ghidra-source.cmake 
    substituteInPlace $sleigh/src/setup-ghidra-source.cmake \
      --replace 'GIT_REPOSITORY https://github.com/NationalSecurityAgency/ghidra' "SOURCE_DIR $ghidra"

    substituteInPlace CMakeLists.txt \
      --replace 'GIT_REPOSITORY https://github.com/lifting-bits/sleigh.git' "SOURCE_DIR $sleigh"

    substituteInPlace 

    bash scripts/build.sh \
      --prefix $out \
      --extra-cmake-args "-DCMAKE_BUILD_TYPE=Release"
  '';

}
