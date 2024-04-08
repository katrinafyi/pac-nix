final: prev:
{

  aslp-cpp = prev.callPackage ./aslp-cpp.nix { };

  inherit (final.janeStreet_pac_0_15) aslp asli;

  overlay_janeStreet_0_15 = ofinal: oprev: {

    asli = ofinal.callPackage ./asli.nix { inherit (final) z3; ocaml_z3 = ofinal.z3; };
    aslp = ofinal.asli;
  };
}

