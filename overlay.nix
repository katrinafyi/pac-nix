let
  overlay = final: prev:
    {
      # MOVED: basil-related packages now in ./basil/overlay.nix
      basil = prev.basil;

      update = prev.callPackage ./update.nix { };

      overlay_ocamlPackages = _: _: { };

      ocamlPackages_pac = final.ocamlPackages.overrideScope' final.overlay_ocamlPackages
        // { _overlay = final.overlay_ocamlPackages; };
      ocamlPackages_pac_4_09 = final.ocaml-ng.ocamlPackages_4_09.overrideScope' final.overlay_ocamlPackages
        // { _overlay = final.overlay_ocamlPackages; };

      # llvm-translator packages 
      # ocamlPackages_pac = prev.ocaml-ng.ocamlPackages_4_09.overrideScope'
      #   (ofinal: oprev: {
      #     llvm = ofinal.callPackage ./llvm-translator/ocaml-llvm.nix { llvmPackages = final.llvmPackages_14; };
      #     asl-translator = ofinal.callPackage ./llvm-translator/asl-translator.nix { };
      retdec5 = prev.callPackage ./llvm-translator/retdec5.nix { };
      retdec-uq-pac = prev.callPackage ./llvm-translator/retdec-uq-pac.nix { retdec = final.retdec5; };
      llvm-rtti-eh = prev.callPackage ./llvm-translator/llvm-rtti-eh.nix { };
      alive2 = prev.callPackage ./llvm-translator/alive2.nix { };

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
  ]
  final
  prev
