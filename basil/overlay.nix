let 
  sbt-drv-repo = builtins.fetchTarball {
    url = "https://github.com/zaninime/sbt-derivation/archive/master.tar.gz";
    sha256 = "sha256:0g9dzw734k4qhvc4h88zjbrxdiz6g8kgq7qgbac8jgj8cvns6xry";
  };
  sbt-drv-overlay = import "${sbt-drv-repo}/overlay.nix";

  overlay = final: prev: 
    {
      basil = (prev.callPackage ./basil.nix {})
        # .overrideAttrs { src = prev.lib.cleanSource ~/progs/basil; }
        ;

      godbolt = (prev.callPackage ./godbolt.nix {});
      basil-tool = prev.callPackage ./basil-tool.nix {};

      jre = final.temurin-jre-bin-17;
      jdk = final.temurin-bin-17;
    };
in final: prev: 
  prev.lib.composeExtensions sbt-drv-overlay overlay final prev
