final: prev:
{
  bap-asli-plugin = (prev.callPackage ./bap-asli-plugin.nix { })
    # .overrideAttrs { src = prev.lib.cleanSource ~/progs/bap-asli-plugin; }
  ;

  bap-plugins = prev.callPackage ./bap-plugins.nix { };

  bap-aslp = prev.callPackage ./bap-aslp.nix { };

  bap-primus = prev.callPackage ./bap-primus.nix { };
}
