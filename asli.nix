{ lib,
  fetchFromGitHub,
  ocaml,
  pkgs,
  ocamlPackages
}:


ocamlPackages.buildDunePackage rec {
  pname = "asli";
  version = "unstable-2023-09-14";

  minimalOCamlVersion = "4.09";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp";
    rev = "f20cec4454375fa4d0ff83028f3aee14c8089a62";
    sha256 = "sha256-x6uak84JFUBApIp2+NvghO67o/A2PmqJB7Ve06UideM=";
  };

  checkInputs = [ ocamlPackages.alcotest ];
  buildInputs = [ pkgs.z3 ];
  nativeBuildInputs = (with pkgs; [ ott ]) ++ (with ocamlPackages; [ menhir ]);
  propagatedBuildInputs = [ pkgs.pcre ] ++ (with ocamlPackages; [ linenoise pprint zarith z3 ocaml_pcre ]);
  doCheck = lib.versionAtLeast ocaml.version "4.09";

  configurePhase = ''
    export ASLI_OTT=${pkgs.ott.out + "/share/ott"}
    mkdir -p $out/share/asli
    cp -rv prelude.asl mra_tools tests $out/share/asli
  '';

  outputs = [ "out" ];

  meta = {
    homepage = "https://github.com/UQ-PAC/aslp";
    description = "ASL partial evaluator to extract semantics from ARM's MRA.";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
