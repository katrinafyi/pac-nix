let
  mill-drv-overlay = import ../mill-derivation/overlay.nix;

  overlay = final: prev: {
    basil = (prev.callPackage ./basil.nix {
      jdk = final.jdk21_headless;
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

  };
in
final: prev:
prev.lib.composeManyExtensions
  [
    overlay
    mill-drv-overlay
  ]
  final
  prev
