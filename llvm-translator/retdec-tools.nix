{ retdec }:

retdec.overrideAttrs (final: prev: { 
  cmakeFlags = prev.cmakeFlags ++ [ "-DRETDEC_DEV_TOOLS=1" ]; 
  doInstallCheck = false;
})
