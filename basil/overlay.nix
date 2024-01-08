final: prev:
{
  basil = (prev.callPackage ./basil.nix { })
    # .overrideAttrs { src = prev.lib.cleanSource ~/progs/basil; }
  ;

  godbolt = (prev.callPackage ./godbolt.nix { });
  basil-tool = prev.callPackage ./basil-tool.nix { };

  jre = final.temurin-jre-bin-17;
  jdk = final.temurin-bin-17;
}
