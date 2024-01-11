let
  overlay = final: prev:
    {
      # MOVED: basil-related packages now in ./basil/overlay.nix
      basil = prev.basil;

      # llvm-translator packages 
      ocaml-llvm = prev.callPackage ./llvm-translator/ocaml-llvm.nix { libllvm = final.llvmPackages_14.libllvm; };
      asl-translator = prev.callPackage ./llvm-translator/asl-translator.nix { };
      retdec5 = prev.callPackage ./llvm-translator/retdec5.nix { };
      retdec-uq-pac = prev.callPackage ./llvm-translator/retdec-uq-pac.nix { retdec = final.retdec5; };
      llvm-rtti-eh = prev.callPackage ./llvm-translator/llvm-rtti-eh.nix { };
      alive2 = prev.callPackage ./llvm-translator/alive2.nix { };
    };
in
final: prev:
prev.lib.composeManyExtensions
  [
    overlay
    (import ./aslp/overlay.nix)
    (import ./bap/overlay.nix)
    (import ./basil/overlay.nix)
    (import ./gtirb/overlay.nix)
  ]
  final
  prev
