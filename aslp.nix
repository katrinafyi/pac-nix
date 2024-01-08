{ stdenv, makeBinaryWrapper, asli, testers, aslp }:
stdenv.mkDerivation {
  pname = "aslp";
  version = asli.version;
  buildInputs = [ asli ];
  nativeBuildInputs = [ makeBinaryWrapper ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin

    ASL_PATH=${asli}/share/asli
    cd ${asli}/bin
    makeBinaryWrapper "$(pwd)/asli" $out/bin/aslp \
      --append-flags --prelude \
      --append-flags $ASL_PATH/prelude.asl \
      --append-flags $ASL_PATH/prelude.asl \
      --append-flags $ASL_PATH/mra_tools/arch/regs.asl \
      --append-flags $ASL_PATH/mra_tools/types.asl \
      --append-flags $ASL_PATH/mra_tools/arch/arch.asl \
      --append-flags $ASL_PATH/mra_tools/arch/arch_instrs.asl \
      --append-flags $ASL_PATH/mra_tools/arch/arch_decode.asl \
      --append-flags $ASL_PATH/mra_tools/support/aes.asl \
      --append-flags $ASL_PATH/mra_tools/support/barriers.asl \
      --append-flags $ASL_PATH/mra_tools/support/debug.asl \
      --append-flags $ASL_PATH/mra_tools/support/feature.asl \
      --append-flags $ASL_PATH/mra_tools/support/hints.asl \
      --append-flags $ASL_PATH/mra_tools/support/interrupts.asl \
      --append-flags $ASL_PATH/mra_tools/support/memory.asl \
      --append-flags $ASL_PATH/mra_tools/support/stubs.asl \
      --append-flags $ASL_PATH/tests/override.asl
  '';

  passthru.tests.aslp-sem = testers.testVersion {
    package = aslp;
    command = ''echo :help | aslp'';
    version = '':sem'';
  };
}
