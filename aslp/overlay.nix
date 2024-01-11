final: prev:
{
  asli = (prev.callPackage ./asli.nix { })
    # .overrideAttrs { src = prev.lib.cleanSource ~/progs/aslp; }
  ;

  aslp = prev.callPackage ./aslp.nix { };
}
