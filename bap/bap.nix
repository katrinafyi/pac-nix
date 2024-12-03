{ makeBinaryWrapper, symlinkJoin, orig-bap, z3 }:

# XXX: fix in ocamlPackages.bap of upstream nixpkgs

symlinkJoin {
  name = "bap-wrapped";
  inherit (orig-bap) version;
  paths = [ orig-bap ];
  nativeBuildInputs = [ makeBinaryWrapper ];
  postBuild = ''
    wrapProgram $out/bin/bap --prefix DYLD_FALLBACK_LIBRARY_PATH : ${z3.lib}/lib
  '';
}
