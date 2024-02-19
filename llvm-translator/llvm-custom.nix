{ lib
, llvmPackages
}:

let
  tools = llvmPackages.tools.extend (finaltools: prevtools: {

    libllvm = prevtools.libllvm.overrideAttrs (final: prev: {
      cmakeFlags = prev.cmakeFlags ++ [
        "-DLLVM_ENABLE_RTTI=ON"
        "-DLLVM_ENABLE_EH=ON"
        "-DLLVM_TARGETS_TO_BUILD=X86;AArch64;ARM"
      ];
      doCheck = false;

      # install Target .inc files from build directory for lifter project.
      postFixup = ''
        cd /build/$sourceRoot/build/lib && file Target
        find Target -name '*.inc' -print0 \
          | xargs -0 -I{} cp -v --no-clobber --parents {} $dev/include
      '';
    });

  });

  noExtend = extensible: lib.attrsets.removeAttrs extensible [ "extend" ];
in
with llvmPackages;
{ inherit tools libraries release_version; } // (noExtend libraries) // (noExtend tools)
# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/development/compilers/llvm/git/default.nix
