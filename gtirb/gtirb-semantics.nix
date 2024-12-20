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
, ppx_jane
, lwt
, lru_cache
, mtime
}:

let
  wrapper = writeShellApplication {
    name = "basil-svcomp";
    text = ''

      tar -ztvf ${out}/svcomp20.tar.gz | grep '.gts$' | sed 's/  / /' | cut -d' ' -f 6 | sed 's/\.gts//'

      exit 1
    '';
  };

  pth = makePythonPth python3Packages "gtirb-semantics" [ protobuf libllvm ];
  python' = python3Packages.python.withPackages
    (p: [ pth python-gtirb ]);

in
buildDunePackage {
  pname = "gtirb_semantics";
  version = "0-unstable-2024-12-19";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "gtirb-semantics";
    rev = "caching";
    hash = "sha256-c4WZn8+X6/AkMBQ2v9eRfmVwoc1PDVfuobw2BJ8cqPQ=";
  };

  buildInputs = [ python' asli ocaml-hexstring ocaml-protoc-plugin yojson  ppx_jane lwt lru_cache mtime ];
  nativeBuildInputs = [ protobuf ocaml-protoc-plugin ];
  propagatedBuildInputs = [ base64 ];

  postInstall = ''
    ln -sv ${wrapper}/bin/* $out/bin/gtirb-semantics-nix
    cp -v $src/scripts/*.py $out/bin
    mv -v $out/bin/{gtirb_semantics,gtirb-semantics}
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
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
