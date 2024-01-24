{ lib
, fetchFromGitHub
, protobuf
, asli
, buildDunePackage
, ocaml-protoc-plugin
, ocaml-hexstring
, base64
, yojson
, writeShellApplication
, makeWrapper
}:

buildDunePackage rec {
  pname = "gtirb_semantics";
  version = "unstable-2024-01-24";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "gtirb-semantics";
    rev = "c65af262e6b9396792e24896cbf69d2cd77f4b07";
    sha256 = "sha256-XghS2DT50prDw3crUyuFp1zm9vtyY/Jf/Sg3UyG5K5o=";
  };

  checkInputs = [ ];
  buildInputs = [ asli ocaml-hexstring ocaml-protoc-plugin yojson ];
  nativeBuildInputs = [ makeWrapper protobuf ocaml-protoc-plugin ];
  propagatedBuildInputs = [ base64 ];

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
