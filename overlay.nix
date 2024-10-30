let
  overlay = final: prev:
    {
      # MOVED: basil-related packages now in ./basil/overlay.nix
      # basil = prev.basil;

      update = prev.callPackage ./update.nix { };

      ocamlPackages_pac = final.ocaml-ng.ocamlPackages_4_14.overrideScope final.overlay_ocamlPackages
        // { _overlay = final.overlay_ocamlPackages; };
      ocamlPackages_pac_5 = final.ocamlPackages.overrideScope final.overlay_ocamlPackages
        // { _overlay = final.overlay_ocamlPackages; };

      # llvm-translator packages 
      overlay_ocamlPackages = ofinal: oprev: {
        ocaml-llvm-14 = ofinal.callPackage ./llvm-translator/ocaml-llvm.nix { libllvm = final.llvmPackages_14.libllvm; };
        asl-translator = ofinal.callPackage ./llvm-translator/asl-translator.nix { llvm = ofinal.ocaml-llvm-14; };
      };
      inherit (final.ocamlPackages_pac) asl-translator;

      retdec5 = prev.callPackage ./llvm-translator/retdec5.nix { };
      retdec-uq-pac = prev.callPackage ./llvm-translator/retdec-uq-pac.nix { retdec = final.retdec5; };

      llvm-custom-15 = prev.callPackage ./llvm-translator/llvm-custom.nix { llvmPackages = final.llvmPackages_15; };
      llvm-custom-18 = prev.callPackage ./llvm-translator/llvm-custom.nix { llvmPackages = final.llvmPackages_18; };
      llvm-custom-git = prev.callPackage ./llvm-translator/llvm-custom.nix {
        llvmPackages = final.llvmPackages_git.override {
          gitRelease = {
            rev = "62ff85f0799560b42754ef77b5f64ca2c7feeff7";
            rev-version = "20.0.0-unstable-2024-10-30";
            sha256 = "sha256-vE1N81PtykTIwVF26pE6ewbi18RI+KEAvDg+ZEI8tfo=";
          };
        };
      };

      alive2 = prev.callPackage ./llvm-translator/alive2.nix {
        llvmPackages = final.llvm-custom-15;
      };
      alive2-regehr = prev.callPackage ./llvm-translator/alive2-regehr.nix {
        llvmPackages = final.llvm-custom-git;
      };
      alive2-aslp = (prev.callPackage ./llvm-translator/alive2-aslp.nix {
        llvmPackages = final.llvm-custom-git;
      }).overrideAttrs {
        # src = ~/progs/alive2-regehr;
      };
      xed2022 = prev.xed.overrideAttrs rec {
        version = "2022.08.11";
        src = prev.fetchFromGitHub {
          owner = "intelxed";
          repo = "xed";
          rev = "v${version}";
          sha256 = "sha256-Iil+dfjuWYPbzmSjgwKTKScSE/IsWuHEKQ5HsBJDqWM=";
        };
      };
      remill = prev.callPackage ./llvm-translator/remill.nix { xed = final.xed2022; };
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
