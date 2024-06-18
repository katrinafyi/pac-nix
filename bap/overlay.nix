final: prev:
{
  overlay_ocamlPackages = ofinal: oprev: {
    bap = oprev.bap.overrideAttrs (p: {
      # configurePhase = ''
      # runHook preConfigure
      # echo old "$configureFlags"
      # configureFlags="--prefix=$prefix $(echo "$configureFlags" | sed -e 's/--\(old\)\?includedir=[^ ]\+//g')"
      # echo new "$configureFlags"
      # ./configure $configureFlags
      # runHook postConfigure
      # '';
      # outputs = final.lib.unique (p.outputs or ["out"] ++ []);
    });

    bap-asli-plugin = (ofinal.callPackage ./bap-asli-plugin.nix { })
      # .overrideAttrs { src = prev.lib.cleanSource ~/progs/bap-asli-plugin; }
    ;

    bap-aslp = ofinal.callPackage ./bap-aslp.nix { };
    bap-plugins = ofinal.callPackage ./bap-plugins.nix { };
    bap-primus = ofinal.callPackage ./bap-primus.nix { };

    # janeStreet = ofinal.janeStreet_0_15;
    janeStreet_0_15 = oprev.janeStreet_0_15.overrideScope (jfinal: jprev: {
      bap-dune = let
        ppxlib = ofinal.ppxlib.override { inherit (jfinal) stdio; };
        lwt_ppx = ofinal.lwt_ppx.override { inherit ppxlib; };
        sedlex = ofinal.sedlex.override { inherit ppxlib; inherit (jprev) ppx_expect; };
        piqi = oprev.piqi.override { inherit sedlex; };
        in jfinal.callPackage ./bap-dune.nix {
          # inherit (pkgs.llvmPackages_14) llvm;
          inherit piqi;
          ezjsonm = oprev.ezjsonm.override { inherit (jprev) sexplib0; };
          ppx_bitstring = oprev.ppx_bitstring.override { inherit ppxlib; };
          ocurl = oprev.ocurl.override { inherit lwt_ppx; };
          piqi-ocaml = oprev.piqi-ocaml.override { inherit piqi; };
        };
    });
  };

  inherit (final.ocamlPackages_pac) bap-aslp bap-asli-plugin bap-primus;
}
