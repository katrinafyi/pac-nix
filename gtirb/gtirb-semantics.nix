{ lib
, buildDunePackage
, fetchFromGitHub
, testVersion
, protobuf
, asli
, llvmPackages
, ocaml-protoc-plugin
, ctypes
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

  libllvm = llvmPackages.libllvm;
  # debug-gts needs llvm-mc at runtime
  pth = makePythonPth python3Packages "gtirb-semantics" [ protobuf libllvm ];
  python' = python3Packages.python.withPackages
    (p: [ pth python-gtirb ]);
in
buildDunePackage {
  pname = "gtirb_semantics";
  version = "unstable-2024-02-21";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "gtirb-semantics";
    rev = "23fe5e2ac50aded95f1447d66aaec14e0bde4814";
    sha256 = "sha256-Y0nFoCCFFcHhyb3lsOYkA4qMT03eElmaMdVeuCnMMHs=";
  };

  buildInputs = [ python' asli ctypes ocaml-protoc-plugin yojson libllvm ];
  nativeBuildInputs = [ protobuf ocaml-protoc-plugin libllvm ];
  propagatedBuildInputs = [ base64 ];

  preConfigure = ''
    substituteInPlace llvm-disas/dune \
      --replace-warn 'opam var' echo \
      --replace-warn conf-llvm:config $(command -v llvm-config)
  '';

  postInstall = ''
    ln -sv ${wrapper}/bin/* $out/bin/gtirb-semantics-nix
    cp -v $src/scripts/*.py $out/bin
    mv -v $out/bin/{gtirb_semantics,gtirb-semantics}
  '';

  outputs = [ "out" "dev" ];

  passthru.tests.gtirb-semantics = testVersion {
    package = gtirb-semantics;
    command = "gtirb-semantics --help";
    version = "gtirb-semantics";
  };
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
