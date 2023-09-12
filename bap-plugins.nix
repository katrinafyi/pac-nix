{ symlinkJoin, ocamlPackages, makeWrapper, plugins ? []}:
  symlinkJoin {
    name = "bap-plugins";
    version = ocamlPackages.bap.version;

    paths = [ ocamlPackages.bap ];
    buildInputs = [ makeWrapper ];
    postBuild = ''
      for x in ${toString plugins}; do
        if ! [[ -d "$x/lib/bap" ]]; then
          echo "$x/lib/bap" plugin path does not exist >&2
          false
        fi
      done

      for b in $out/bin/*; do 
        wrapProgram $b \
          --append-flags "${toString (map (x: "-L ${x + "/lib/bap"}") plugins)}"
      done
    '';
  }
