{ lib
, callPackage
, path
, llvmPackages
}:

llvmPackages.overrideScope (_: prev: {
  libllvm = prev.libllvm.overrideAttrs (_: prev: {
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
})
