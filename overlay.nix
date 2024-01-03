let 
  overlay = final: prev: 
    {
      ocamlPackages = prev.ocamlPackages.overrideScope'
        (ofinal: oprev:
          { bap = oprev.bap.override { llvm = final.llvm_11; }; });

      asli = (prev.callPackage ./asli.nix {})
        # .overrideAttrs { src = prev.lib.cleanSource ~/progs/aslp; }
        ;

      aslp = prev.callPackage ./aslp.nix {};

      bap-asli-plugin = (prev.callPackage ./bap-asli-plugin.nix {})
        # .overrideAttrs { src = prev.lib.cleanSource ~/progs/bap-asli-plugin; }
        ;

      bap-plugins = prev.callPackage ./bap-plugins.nix {};

      bap-aslp = prev.callPackage ./bap-aslp.nix {};

      bap-primus = prev.callPackage ./bap-primus.nix {};

      gtirb-semantics = prev.callPackage ./gtirb-semantics.nix {};
      ocaml-hexstring = prev.callPackage ./ocaml-hexstring.nix {};

      # MOVED: basil-related packages now in ./basil/overlay.nix
      basil = prev.basil;

      # llvm-translator packages 
      ocaml-llvm = prev.callPackage ./llvm-translator/ocaml-llvm.nix { libllvm = final.llvmPackages_14.libllvm; };
      asl-translator = prev.callPackage ./llvm-translator/asl-translator.nix {};
      retdec5 = prev.callPackage ./llvm-translator/retdec5.nix {};
      retdec-uq-pac = prev.callPackage ./llvm-translator/retdec-uq-pac.nix { retdec = final.retdec5; };
      llvm-rtti-eh = prev.callPackage ./llvm-translator/llvm-rtti-eh.nix {};
      alive2 = prev.callPackage ./llvm-translator/alive2.nix {};
    };
in final: prev: 
  prev.lib.composeManyExtensions
    [ overlay (import ./basil/overlay.nix) ]
    final prev
