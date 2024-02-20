{ lib
, buildEnv
, runCommandLocal
, writeShellApplication
, gcc-aarch64
, clang-aarch64
, ddisasm
, gtirb-semantics
, asli
}:

let
  planter-deps = [ gcc-aarch64 clang-aarch64 ddisasm.deterministic asli gtirb-semantics ];
  planter-versions = lib.escapeShellArgs (builtins.map builtins.toString planter-deps);
  planter = writeShellApplication {
    name = "planter";
    runtimeInputs = planter-deps;
    checkPhase = ":";

    text = ''
      usage="usage: $0 [--help] [--version] [-v] {gcc,clang} INPUT_C_FILE OUTPUT_BINARY OUTPUT_GTIRB OUTPUT_GTS"

      if [[ " $@ " == *' --version '* ]]; then
        echo "$0 versions:" >&2
        printf '  %s\n' ${planter-versions} >&2
        exit 0
      elif [[ " $@ " == *' --help '* ]]; then
        echo "$usage" >&2
        exit 0
      fi

      args=()
      verbose=false
      for a in "$@"; do
        if [[ "$a" == -v ]]; then
          verbose=true
        else
          args+=("$a")
        fi
      done

      if [[ -z "''${NIX_STORE:-}" ]]; then
        export NIX_BUILD_TOP=$(pwd)
        export NIX_STORE=/nix/store
        export NIX_ENFORCE_PURITY=1
      fi

      if [[ ''${#args[@]} != 5 ]]; then
        echo "$usage" >&2
        exit 1
      fi
      if $verbose; then
        set -x
      fi

      compiler="''${args[0]}"
      in="''${args[1]}"
      out="''${args[2]}"
      gtirb="''${args[3]}"
      gts="''${args[4]}"

      ${gcc-aarch64.targetPrefix}"$compiler" ''${CFLAGS:-} "$in" -o "$out"
      ddisasm-deterministic "$out" --ir "$gtirb"
      gtirb-semantics "$gtirb" "$gts"
    '';
  };
in
buildEnv {
  name = "planter-env";

  pathsToLink = "/bin";
  paths = [
    gcc-aarch64
    clang-aarch64
    planter
  ];

  ignoreCollisions = true;

  passthru.tests.planter-det =
    runCommandLocal
      "planter-det"
      { nativeBuildInputs = [ planter ] ++ planter-deps; }
      ''
        trap 'set +x' EXIT
        set -x

        export NIX_HARDENING_ENABLE=
        export NIX_LDFLAGS="''${NIX_LDFLAGS/-rpath $out\/lib/}"
        env

        mkdir $out && cd $out
        echo 'int main(void){return 3;}' > a.c

        for cc in gcc clang; do
          mkdir $cc && cd $cc
          cp ../a.c .
          planter $cc a.c a.out a.gtirb a.gts
          planter $cc a.c a.out a.gtirb b.gts
          proto-json.py a.gts a.json
          proto-json.py b.gts b.json
          diff -q a.json b.json
          cd ..
        done

        md5sum gcc/* clang/* > $out/md5sum
      '';

  meta = {
    mainProgram = "planter";
  };
}
