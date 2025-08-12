{ lib
, callPackage
, path
}:

let
  llvmPackages' = callPackage (path + "/pkgs/development/compilers/llvm") {
    overrideAttrsFn = final: prev: if prev.pname == "llvm" then {
      cmakeFlags = prev.cmakeFlags ++ [
        "-DLLVM_ENABLE_RTTI=ON"
        "-DLLVM_ENABLE_EH=ON"
        "-DLLVM_ENABLE_ASSERTIONS=ON"  # alive2 needs NDEBUG unset
        "-DLLVM_TARGETS_TO_BUILD=AArch64;ARM;RISCV"
      ];
      doCheck = false;

      # install Target .inc files from build directory for lifter project.
      # at this point, we should within the build artifact directory
      postBuild = ''
        mkdir -p $dev/include
        pushd ./lib
        file Target
        find Target -name '*.inc' -print0 \
          | xargs -0 -I{} cp -v --no-clobber --parents {} $dev/include
        popd
      '';
    } else {};
  };
in
  (llvmPackages'.mkPackage {
    version = "22.0.0-git";
    # XXX: directly pull gitRelease from nixpkgs somehow
    gitRelease = {
      rev = "144cd87088dc82263b25e816c77fc03f29fd1288";
      rev-version = "22.0.0-unstable-2025-08-03";
      sha256 = "sha256-DtY1OcpquPQ+dXTyuVggrK5gO7H5xgoZajf/ZONCQ7o=";
    };
    name = "pac";
  }).value
# https://github.com/NixOS/nixpkgs/blob/52a9f2036eb3a139453459b16904b972a0984f9a/pkgs/development/compilers/llvm/common/default.nix
