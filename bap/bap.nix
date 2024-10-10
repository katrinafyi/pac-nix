{ stdenv, makeBinaryWrapper, symlinkJoin, orig-bap, z3 }:

symlinkJoin {
  inherit (orig-bap) version;
  name = "bap-wrapped";
  paths = [ orig-bap ];
  nativeBuildInputs = [ makeBinaryWrapper ];
  postBuild = ''
    wrapProgram $out/bin/bap --prefix DYLD_FALLBACK_LIBRARY_PATH : ${z3.lib}/lib
  '';
}
