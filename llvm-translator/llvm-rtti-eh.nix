{ llvmPackages }:

llvmPackages.libllvm.overrideAttrs (final: prev: {
  cmakeFlags = prev.cmakeFlags ++ [
    "-DLLVM_ENABLE_RTTI=ON"
    "-DLLVM_ENABLE_EH=ON"
    "-DLLVM_TARGETS_TO_BUILD=X86;AArch64;ARM"
  ];
  doCheck = false;
})
