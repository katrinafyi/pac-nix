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
    godbolt = final.compiler-explorer;

    basil-tool = prev.callPackage ./basil-tool.nix { };
    basil-task = prev.callPackage ./basil-task.nix { };

    gtirb-semantics-server-docker = final.callPackage ./gtirb-semantics-server-docker.nix { };

    godbolt-docker-compose = ./godbolt-docker-compose.yml;

    start-godbolt = final.callPackage ./start-godbolt.nix { };

    basls = final.ocamlPackages_pac_5.basil_lsp;

    overlay_ocamlPackages = ofinal: oprev: {
      basil_ast = ofinal.callPackage ./basls.nix { } "basil_ast";
      basil_lsp = ofinal.callPackage ./basls.nix { } "basil_lsp";
    };

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
