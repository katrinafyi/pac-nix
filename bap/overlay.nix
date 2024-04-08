final: prev:
{
  overlay_janeStreet_0_15 = ofinal: oprev: {

    bap-asli-plugin = (ofinal.callPackage ./bap-asli-plugin.nix { })
      # .overrideAttrs { src = prev.lib.cleanSource ~/progs/bap-asli-plugin; }
    ;

    bap-aslp = ofinal.callPackage ./bap-aslp.nix { };
    bap-plugins = ofinal.callPackage ./bap-plugins.nix { };
    bap-primus = ofinal.callPackage ./bap-primus.nix { };
  };

  inherit (final.janeStreet_pac_0_15) bap-aslp bap-asli-plugin bap-primus;
}
