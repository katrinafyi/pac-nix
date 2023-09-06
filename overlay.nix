final: prev: 
  {
    asli = prev.callPackage ./asli.nix {};
    aslp = prev.callPackage ./aslp.nix {};

    asli-plugin = prev.callPackage ./bap-asli-plugin.nix {};

    bap-plugins = prev.callPackage ./bap-plugins.nix {};

    bap-aslp = prev.callPackage ./bap-aslp.nix {};

    basil = prev.callPackage ./basil.nix {};

    jre = final.temurin-jre-bin-17;
    jdk = final.temurin-bin-17;
  }
