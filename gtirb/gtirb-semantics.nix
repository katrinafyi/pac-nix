{ lib
, buildDunePackage
, fetchFromGitHub
, testVersion
, protobuf
, asli
, libllvm
, ocaml-protoc-plugin
, ocaml-hexstring
, base64
, yojson
, writeShellApplication
, makePythonPth
, python3Packages
, python-gtirb
, gtirb-semantics
}:

let
  wrapper = writeShellApplication {
    name = "gtirb-semantics-wrapper";
    text = ''
      # gtirb-semantics-wrapper: wrapper script for executing gtirb_semantics when packaged by Nix.
      # this inserts the required ASLI arguments, and passes through the user's input/output arguments.

      prog="$(dirname "$0")"/gtirb_semantics
      input="$1"
      shift
      
      echo '$' "$(basename "$prog")" "$input" ${baseNameOf asli.prelude} ${baseNameOf asli.mra_tools}/ ${baseNameOf asli.dir}/ "$@" >&2
      "$prog" "$input" ${asli.prelude} ${asli.mra_tools} ${asli.dir} "$@"
    '';
  };

  pth = makePythonPth python3Packages "gtirb-semantics" [ protobuf libllvm ];
  python' = python3Packages.python.withPackages
    (p: [ pth python-gtirb ]);

in
buildDunePackage {
  pname = "gtirb_semantics";
  version = "unstable-2024-02-09";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "gtirb-semantics";
    rev = "300525170d534903775d9b19abf3ed5d3d20728b";
    sha256 = "sha256-wDda+btWoeGEfJQJg7y7MrqzSl7DnOeff2sb81oxmKo=";
  };

  buildInputs = [ python' asli ocaml-hexstring ocaml-protoc-plugin yojson ];
  nativeBuildInputs = [ protobuf ocaml-protoc-plugin ];
  propagatedBuildInputs = [ base64 ];

  postInstall = ''
    ln -sv ${wrapper}/bin/* $out/bin/gtirb-semantics-nix
    cp -v $src/scripts/*.py $out/bin 
  '';

  outputs = [ "out" "dev" ];

  passthru.tests.test-debug-gts = testVersion {
    package = gtirb-semantics;
    command = "debug-gts.py --help";
    version = "debug-gts.py";
  };
  passthru.tests.test-proto-json = testVersion {
    package = gtirb-semantics;
    command = "proto-json.py --help";
    version = "proto-json.py";
  };

  meta = {
    homepage = "https://github.com/UQ-PAC/gtirb-semantics";
    description = "Add instruction semantics to the IR of a dissassembled ARM64 binary";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
