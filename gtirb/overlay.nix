final: prev:
{
  ddisasm = prev.callPackage ./ddisasm.nix { };
  gtirb = prev.callPackage ./gtirb.nix { };
  gtirb-pprinter = prev.callPackage ./gtirb-pprinter.nix { };
  capstone-grammatech = prev.callPackage ./capstone-grammatech.nix { };

  libehp = prev.callPackage ./libehp.nix { };

  overlay_ocamlPackages = ofinal: oprev: {
    ocaml-hexstring = ofinal.callPackage ./ocaml-hexstring.nix { };
    gtirb-semantics = ofinal.callPackage ./gtirb-semantics.nix { };
  };

  inherit (final.ocamlPackages_pac) gtirb-semantics;

  proto-json = prev.callPackage ./proto-json.nix {
    inherit (final.ocamlPackages_pac) gtirb-semantics;
  };
}
