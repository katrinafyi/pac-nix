{ lib
, llvmPackages
}:

let
  overlay = finaltools: prevtools: {

    libllvm = prevtools.libllvm.overrideAttrs (final: prev: {
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
    });
  };

  tools = llvmPackages.tools.extend overlay;

  noExtend = extensible: lib.attrsets.removeAttrs extensible [ "extend" ];
in
with llvmPackages;
{ inherit tools libraries release_version; } // (noExtend libraries) // (noExtend tools)
# https://github.com/NixOS/nixpkgs/blob/52a9f2036eb3a139453459b16904b972a0984f9a/pkgs/development/compilers/llvm/common/default.nix
