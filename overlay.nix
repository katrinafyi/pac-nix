let 
  sbt-drv-repo = builtins.fetchTarball {
    url = "https://github.com/zaninime/sbt-derivation/archive/master.tar.gz";
  };
  sbt-drv-overlay = import "${sbt-drv-repo}/overlay.nix";

  overlay = final: prev: 
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

      bap-uq-pac = prev.callPackage ./bap-uq-pac.nix {};

      basil = (prev.callPackage ./basil.nix {})
        # .overrideAttrs { src = prev.lib.cleanSource ~/progs/basil; }
        ;

      jre = final.temurin-jre-bin-17;
      jdk = final.temurin-bin-17;


      # llvm-translator packages 
      asl-translator = prev.callPackage ./llvm-translator/asl-translator.nix {};
      retdec-tools = prev.callPackage ./llvm-translator/retdec-tools.nix {};
      llvm-rtti-eh = prev.callPackage ./llvm-translator/llvm-rtti-eh.nix {};
      alive2 = prev.callPackage ./llvm-translator/alive2.nix {};

    };
in final: prev: 
  prev.lib.composeExtensions sbt-drv-overlay overlay final prev
