{ llvmPackages }:

llvmPackages.libllvm.overrideAttrs (final: prev: {
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
})
