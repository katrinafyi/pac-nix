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
      echo 'gtirb-semantics-nix is no longer needed, please use gtirb-semantics instead.' >&2
      exit 1
    '';
  };

  pth = makePythonPth python3Packages "gtirb-semantics" [ protobuf libllvm ];
  python' = python3Packages.python.withPackages
    (p: [ pth python-gtirb ]);

in
buildDunePackage {
  pname = "gtirb_semantics";
  version = "unstable-2024-02-16";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "gtirb-semantics";
    rev = "1e237362136b3fe24f1ecbb537b8c19c165bdabd";
    sha256 = "sha256-uC9ZB7i3m92DJxiUJ8AwDwb35kRZELKAW/u2sVLsd1g=";
  };

  buildInputs = [ python' asli ocaml-hexstring ocaml-protoc-plugin yojson ];
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
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
