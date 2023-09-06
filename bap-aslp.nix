{ stdenv, makeBinaryWrapper, bap-plugins, asli, bap-asli-plugin }:
  let _bap = (bap-plugins.override { plugins = [ asli-plugin ]; });
  in stdenv.mkDerivation {
    pname = "bap-aslp";
    version = _bap.version;
    buildInputs = [ _bap asli ];
    nativeBuildInputs = [ makeBinaryWrapper ];
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin

      ASLI_PATH=${asli}/asl
      cd ${_bap}/bin
      for b in *; do 
        makeBinaryWrapper "$(pwd)/$b" $out/bin/$b-aslp \
          --append-flags --primus-lisp-semantics=disable \
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
      done
    '';
  }
