{ stdenv, makeBinaryWrapper, bap-plugins, asli, bap-asli-plugin, testers, bap-aslp, pcre }:

let _bap = (bap-plugins.override { suffix = ""; plugins = [ bap-asli-plugin ]; });
in stdenv.mkDerivation {
  pname = "bap-aslp";
  version = bap-asli-plugin.version;
  unpackPhase = ":";
  buildInputs = [ makeBinaryWrapper ];
  postBuild = ''
    ASLI_PATH=${asli}/share/asli

    mkdir -p $out/bin
    cd ${_bap}/bin
    for b in *; do 
      if ! [[ -f $b ]]; then
        continue
      fi
      if [[ $b != bap ]]; then
        makeBinaryWrapper "$(pwd)/$b" $out/bin/$b
      else
        makeBinaryWrapper "$(pwd)/$b" $out/bin/$b \
          --append-flags --no-primus-lisp \
          --append-flags --asli-prelude=$ASLI_PATH/prelude.asl \
          --append-flags --asli-specs=$ASLI_PATH/mra_tools/arch/regs.asl \
          --append-flags --asli-specs=$ASLI_PATH/mra_tools/types.asl \
          --append-flags --asli-specs=$ASLI_PATH/mra_tools/arch/arch.asl \
          --append-flags --asli-specs=$ASLI_PATH/mra_tools/arch/arch_instrs.asl \
          --append-flags --asli-specs=$ASLI_PATH/mra_tools/arch/arch_decode.asl \
          --append-flags --asli-specs=$ASLI_PATH/mra_tools/support/aes.asl \
          --append-flags --asli-specs=$ASLI_PATH/mra_tools/support/barriers.asl \
          --append-flags --asli-specs=$ASLI_PATH/mra_tools/support/debug.asl \
          --append-flags --asli-specs=$ASLI_PATH/mra_tools/support/feature.asl \
          --append-flags --asli-specs=$ASLI_PATH/mra_tools/support/hints.asl \
          --append-flags --asli-specs=$ASLI_PATH/mra_tools/support/interrupts.asl \
          --append-flags --asli-specs=$ASLI_PATH/mra_tools/support/memory.asl \
          --append-flags --asli-specs=$ASLI_PATH/mra_tools/support/stubs.asl \
          --append-flags --asli-specs=$ASLI_PATH/tests/override.asl
      fi
    done
  '';

  passthru.tests.asli = testers.testVersion {
    package = bap-aslp;
    command = "bap --help";
    version = "asli-specs";
  };

  meta = {
    broken = true;
  };
}

