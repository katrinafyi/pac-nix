{ fetchurl, retdec }:

retdec.overrideAttrs (final: prev: {
  cmakeFlags = prev.cmakeFlags ++ [ "-DRETDEC_DEV_TOOLS=1" ];
  patches = [
    (fetchurl {
      url = "https://gist.githubusercontent.com/katrinafyi/c33f6f9ccaad4420f76f84e6cb219fe0/raw/0001-emit-names-for-capstone-intrinsics.patch";
      hash = "sha256-LJjzLw2R8ckB10jL92RH/kHggX2oQrAZNQUsonM6ciQ=";
    })
  ];
  doInstallCheck = false;
})
