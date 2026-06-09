final: prev:
{
  lief-static = prev.lief.overrideAttrs (p: {
    version = "0.16.6";
    src = final.fetchFromGitHub {
      owner = "lief-project";
      repo = "LIEF";
      tag = "0.16.6";
      hash = "sha256-SvwFyhIBuG0u5rE7+1OaO7VZu4/X4jVI6oFOm5+yCd8=";
    };
    cmakeFlags = p.cmakeFlags ++ [ (prev.lib.cmakeBool "BUILD_SHARED_LIBS" false) ];
  });

  ddisasm = prev.callPackage ./ddisasm.nix {
    lief = final.lief-static;
  };
  ddisasm-deterministic = prev.ddisasm.deterministic;

  gtirb = prev.callPackage ./gtirb.nix { };
  python-gtirb = prev.callPackage ./python-gtirb.nix {
    python3Packages = final.python311Packages;
  };
  python-retypd = prev.callPackage ./python-retypd.nix { };
  gtirb-pprinter = prev.callPackage ./gtirb-pprinter.nix { };
  capstone-grammatech = prev.callPackage ./capstone-grammatech.nix { };

  libehp = prev.callPackage ./libehp.nix { };

  overlay_ocamlPackages = ofinal: oprev: {
    ocaml-hexstring = ofinal.callPackage ./ocaml-hexstring.nix { };
    gtirb-semantics = ofinal.callPackage ./gtirb-semantics.nix {
      python3Packages = final.python311Packages;
      ocaml-protoc-plugin = ofinal.ocaml-protoc-plugin-6-1-0;
    };

    omd-2-0-0 = oprev.omd.overrideAttrs (p: {
      version = "2.0.0.alpha4";
      src = prev.fetchFromGitHub {
        owner = "ocaml-community";
        repo = "omd";
        rev = "2.0.0.alpha4";
        hash = "sha256-5eZitDaNKSkLOsyPf5g5v9wdZZ3iVQGu8Ot4FHZZ3AI=";
      };
      buildInputs = (p.buildInputs or []) ++ (with ofinal; [ uutf uucp uunf dune-build-info ]);
    });

    # XXX: upstream this + omd!!
    ocaml-protoc-plugin-6-1-0 = oprev.ocaml-protoc-plugin.overrideAttrs (p: {
      version = "6.1.0";
      src = prev.fetchFromGitHub {
        owner = "andersfugmann";
        repo = "ocaml-protoc-plugin";
        rev = "6.1.0";
        hash = "sha256-d7ZpXRL/d6/MY9/wqrDAKsalRqSuQseGLLzA+E3m24o=";
      };
      buildInputs = p.buildInputs ++ (with ofinal; [ dune-configurator omd-2-0-0 ptime base64 final.protobuf ]);
      propagatedBuildInputs = (p.propagatedBuildInputs or []) ++ [ ofinal.ppx_expect ];
      postPatch = ''
        substituteInPlace test/config/discover.ml --replace-fail 'conf.cflags;' '(["-std=c++17"] @ conf.cflags);';
      '';
    });

  };

  inherit (final.ocamlPackages_pac) gtirb-semantics;

  proto-json = prev.callPackage ./proto-json.nix { };

  unrandom = prev.callPackage ./unrandom.nix { };

}
