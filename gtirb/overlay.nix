final: prev:
{
  ddisasm = prev.callPackage ./ddisasm.nix { };
  gtirb = prev.callPackage ./gtirb.nix { };
  gtirb-pprinter = prev.callPackage ./gtirb-pprinter.nix { };
  capstone-grammatech = prev.callPackage ./capstone.nix { };
  libehp = prev.callPackage ./libehp.nix { };

  gtirb-semantics = prev.callPackage ./gtirb-semantics.nix { };

  ocaml-hexstring = prev.callPackage ./ocaml-hexstring.nix { };
}
