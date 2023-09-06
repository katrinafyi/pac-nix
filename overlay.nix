final: prev: 
  {
    asli = (prev.callPackage ./asli.nix {})
      # .overrideAttrs { src = prev.lib.cleanSource ~/progs/aslp; }
      ;

    aslp = prev.callPackage ./aslp.nix {};

    bap-asli-plugin = (prev.callPackage ./bap-asli-plugin.nix {})
      # .overrideAttrs { src = prev.lib.cleanSource ~/progs/bap-asli-plugin; }
      ;

    bap-plugins = prev.callPackage ./bap-plugins.nix {};

    bap-aslp = prev.callPackage ./bap-aslp.nix {};

    basil = (prev.callPackage ./basil.nix {})
      # .overrideAttrs { src = prev.lib.cleanSource ~/progs/basil; }
      ;

    jre = final.temurin-jre-bin-17;
    jdk = final.temurin-bin-17;
  }
