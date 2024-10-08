final: prev:
{
  overlay_ocamlPackages = ofinal: oprev: {
    bapWrapper = ofinal.callPackage ./bap.nix { orig-bap = oprev.bap ; z3 = prev.z3 ; };
    bap = ofinal.bapWrapper.overrideAttrs (p: {
      # configurePhase = ''
      # runHook preConfigure
      # echo old "$configureFlags"
      # configureFlags="--prefix=$prefix $(echo "$configureFlags" | sed -e 's/--\(old\)\?includedir=[^ ]\+//g')"
      # echo new "$configureFlags"
      # ./configure $configureFlags
      # runHook postConfigure
      # '';
      # outputs = final.lib.unique (p.outputs or ["out"] ++ []);
    });

    bap-asli-plugin = (ofinal.callPackage ./bap-asli-plugin.nix { })
      # .overrideAttrs { src = prev.lib.cleanSource ~/progs/bap-asli-plugin; }
    ;

    bap-aslp = ofinal.callPackage ./bap-aslp.nix { };
    bap-plugins = ofinal.callPackage ./bap-plugins.nix { };
    bap-primus = ofinal.callPackage ./bap-primus.nix { };

    bap-build = ofinal.callPackage ./bap-build.nix { };
  };

  inherit (final.ocamlPackages_pac) bap-aslp bap-asli-plugin bap-primus;
}
