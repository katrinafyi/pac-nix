final: prev: 
  {
    asli = (prev.callPackage ./asli.nix {})
      # .overrideAttrs { src = prev.lib.cleanSource ~/progs/aslp; }
      ;

    aslp = prev.callPackage ./aslp.nix {};

    bap-asli-plugin = (prev.callPackage ./bap-asli-plugin.nix {})
      # .overrideAttrs { src = prev.lib.cleanSource ~/progs/bap-asli-plugin; }
      ;

    bap-plugins = prev.callPackage ./bap-plugins.nix {};

    bap-aslp = prev.callPackage ./bap-aslp.nix {};

    bap-uq-pac = prev.ocamlPackages.bap.overrideAttrs rec {
      version = src.rev;
      src = prev.fetchFromGitHub {
        owner = "UQ-PAC";
        repo = "bap";
        rev = "acfdc1067afa847fa1eadac9700eae349434dc3b";
        sha256 = "sha256-FkfwMTbA9QS3vy4rs5Ua4egZg6/gQy3YzUG8xEyFo4A=";
      };
    };

    basil = (prev.callPackage ./basil.nix {})
      # .overrideAttrs { src = prev.lib.cleanSource ~/progs/basil; }
      ;

    jre = final.temurin-jre-bin-17;
    jdk = final.temurin-bin-17;
  }
