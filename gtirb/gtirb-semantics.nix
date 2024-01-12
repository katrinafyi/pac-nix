{ lib
, fetchFromGitHub
, ocaml
, pkgs
, ocamlPackages
, protobuf
, asli
, ocaml-hexstring
, writeShellApplication
, makeWrapper
}:

ocamlPackages.buildDunePackage rec {
  pname = "gtirb_semantics";
  version = "unstable-2024-01-05";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "gtirb-semantics";
    rev = "749509a9aeb2559442b8e530b68bf0aeae5d1180";
    sha256 = "sha256-ZVOaW1Gt3FFgg3xSIyS8CVq4tdTOircq3wyX2mQkQ9c=";
  };

  checkInputs = [ ];
  buildInputs = [ asli ocaml-hexstring ocamlPackages.ocaml-protoc-plugin ];
  nativeBuildInputs = [ makeWrapper protobuf ocamlPackages.ocaml-protoc-plugin ];
  propagatedBuildInputs = (with ocamlPackages; [ base64 ]);
  doCheck = lib.versionAtLeast ocaml.version "4.09";

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

  postInstall = ''
    cp -v ${wrapper}/bin/* $out/bin/gtirb-semantics-nix
  '';

  outputs = [ "out" "dev" ];

  meta = {
    homepage = "https://github.com/UQ-PAC/gtirb-semantics";
    description = "Add instruction semantics to the IR of a dissassembled ARM64 binary";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
