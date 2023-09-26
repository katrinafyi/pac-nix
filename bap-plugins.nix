{ stdenv, ocamlPackages, makeBinaryWrapper, suffix ? "", plugins ? [] }:
let bap = ocamlPackages.bap;
in stdenv.mkDerivation {
  pname = "bap-plugins";
  version = bap.version;
  unpackPhase = ":";
  propagatedBuildInputs = plugins;
  buildInputs = [ makeBinaryWrapper bap ];
  postBuild = ''
    for x in ${toString plugins}; do
      if ! [[ -d "$x/lib/bap" ]]; then
        echo "$x/lib/bap" plugin path does not exist >&2
        false
      fi
    done
    
    mkdir -p $out/bin
    cd ${bap}/bin
    for b in *; do 
      if ! [[ -f $b ]]; then
        continue
      fi
      if [[ $b != bap ]]; then
        makeBinaryWrapper "$(pwd)/$b" $out/bin/$b${suffix}
      else
        makeBinaryWrapper "$(pwd)/$b" $out/bin/$b${suffix} \
          --append-flags "${toString (map (x: "-L ${x + "/lib/bap"}") plugins)}"
      fi
    done
  '';
}
