let
  sbt-drv-repo = builtins.fetchTarball {
    url = "https://github.com/zaninime/sbt-derivation/archive/master.tar.gz";
    sha256 = "sha256:0g9dzw734k4qhvc4h88zjbrxdiz6g8kgq7qgbac8jgj8cvns6xry";
  };
  sbt-drv-overlay = import "${sbt-drv-repo}/overlay.nix";

  mill-drv-overlay = import ../mill-derivation/overlay.nix;

  overlay = final: prev: {
    basil = (prev.callPackage ./basil.nix {
      jdk = final.jdk17;
      jre = final.temurin-jre-bin-17;
    })
      # .overrideAttrs { src = prev.lib.cleanSource ~/progs/basil; }
    ;

    planter = prev.callPackage ./planter.nix { };
    gcc-aarch64 = final.pkgsCross.aarch64-multiplatform.pkgsBuildHost.gcc;
    clang-aarch64 = final.pkgsCross.aarch64-multiplatform.pkgsBuildHost.clang;

    compiler-explorer = (prev.callPackage ./compiler-explorer.nix { });
    godbolt = (prev.callPackage ./godbolt.nix { });
    basil-tool = prev.callPackage ./basil-tool.nix { };
    basil-task = prev.callPackage ./basil-task.nix { };
  };
in
final: prev:
prev.lib.composeManyExtensions
  [
    sbt-drv-overlay
    overlay
    mill-drv-overlay
  ]
  final
  prev
