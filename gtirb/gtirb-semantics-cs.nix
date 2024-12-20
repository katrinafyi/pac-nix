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
, gtirb-semantics
, ppx_jane
, lwt
, lru_cache
, mtime
}:

(gtirb-semantics.override {}).overrideAttrs (prev: {
  pname = "gtirb_semantics_clientserver";
  version = "0-unstable-2024-12-20";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "gtirb-semantics";
    rev = "caching";
    hash = "sha256-c4WZn8+X6/AkMBQ2v9eRfmVwoc1PDVfuobw2BJ8cqPQ=";
  };

  buildInputs = [ asli ocaml-hexstring ocaml-protoc-plugin yojson ppx_jane lwt lru_cache mtime ];
  nativeBuildInputs = [ protobuf ocaml-protoc-plugin ];
  propagatedBuildInputs = [ base64 yojson ];
})
