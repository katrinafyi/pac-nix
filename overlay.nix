let
  overlay = final: prev:
    {
      # MOVED: basil-related packages now in ./basil/overlay.nix
      # basil = prev.basil;

      update = prev.callPackage ./update.nix { };

      ocamlPackages_pac = final.ocaml-ng.ocamlPackages_4_14.overrideScope final.overlay_ocamlPackages
        // { _overlay = final.overlay_ocamlPackages; };
      # ocamlPackages_pac_4_09 = final.ocaml-ng.ocamlPackages_4_09.overrideScope final.overlay_ocamlPackages
      #   // { _overlay = final.overlay_ocamlPackages; };

      # llvm-translator packages 
      overlay_ocamlPackages = ofinal: oprev: {
        llvm = ofinal.callPackage ./llvm-translator/ocaml-llvm.nix { llvmPackages = final.llvmPackages_14; };
        asl-translator = ofinal.callPackage ./llvm-translator/asl-translator.nix { };
      };
      inherit (final.ocamlPackages_pac) asl-translator;
      retdec5 = prev.callPackage ./llvm-translator/retdec5.nix { };
      retdec-uq-pac = prev.callPackage ./llvm-translator/retdec-uq-pac.nix { retdec = final.retdec5; };

      llvm-custom-15 = prev.callPackage ./llvm-translator/llvm-custom.nix { llvmPackages = final.llvmPackages_15; };
      llvm-custom-git = prev.callPackage ./llvm-translator/llvm-custom.nix { llvmPackages = final.llvmPackages_git; };

      alive2 = prev.callPackage ./llvm-translator/alive2.nix {
        llvmPackages = final.llvm-custom-15;
      };
      alive2-regehr = prev.callPackage ./llvm-translator/alive2-regehr.nix {
        llvmPackages = final.llvm-custom-git;
      };
      alive2-aslp = prev.callPackage ./llvm-translator/alive2-aslp.nix { };
      remill = prev.callPackage ./llvm-translator/remill.nix { };
      sleigh = prev.callPackage ./llvm-translator/sleigh.nix { };

      _overlay = overlay;
    };
in
final: prev:
let
  lib = prev.lib;
  composeOverlays = f: g: final: prev:
    with builtins;
    let
      fResult = f final prev;
      gResult = g final (prev // fResult);
    in
    lib.zipAttrsWith
      (k: vs:
        if length vs == 1
        then head vs
        else if lib.hasPrefix "overlay_" k
        then composeOverlays (elemAt vs 0) (elemAt vs 1)
        else elemAt vs 1)
      [ fResult gResult ];
  composeManyOverlays = lib.foldr (x: y: composeOverlays x y) (final: prev: { });
in
composeManyOverlays
  [
    overlay
    (import ./aslp/overlay.nix)
    (import ./bap/overlay.nix)
    (import ./basil/overlay.nix)
    (import ./gtirb/overlay.nix)
    (import ./lib.nix)
  ]
  final
  prev
