{ lib
, fetchFromGitHub
, ocamlPackages
, pcre
, ott
, z3
}:

let
  self = ocamlPackages.buildDunePackage {
    pname = "asli";
    version = "unstable-2024-01-16";

    minimalOCamlVersion = "4.09";

    src = fetchFromGitHub {
      owner = "UQ-PAC";
      repo = "aslp";
      rev = "fc60f76057a35538b7e43c6e128a1b0983b868b8";
      sha256 = "sha256-kQYcprdk+t26eMN6xxIFdWlnNfzvJV9CyMVjv00DYGM=";
    };

    checkInputs = [ ocamlPackages.alcotest ];
    buildInputs = (with ocamlPackages; [ linenoise ]);
    nativeBuildInputs = [ ott ] ++ (with ocamlPackages; [ menhir ]);
    propagatedBuildInputs = [ z3 pcre ] ++ (with ocamlPackages; [ pprint zarith ocamlPackages.z3 ocaml_pcre ]);

    configurePhase = ''
      export ASLI_OTT=${ott.out + "/share/ott"}
      mkdir -p $out/share/asli
      cp -rv prelude.asl mra_tools tests $out/share/asli
    '';

    shellHook = ''
      export ASLI_OTT=${ott.out + "/share/ott"}
    '';

    outputs = [ "out" "dev" ];

    passthru = {
      prelude = "${self.out}/share/asli/prelude.asl";
      mra_tools = "${self.out}/share/asli/mra_tools";
      dir = "${self.out}/share/asli";
    };

    meta = {
      homepage = "https://github.com/UQ-PAC/aslp";
      description = "ASL partial evaluator to extract semantics from ARM's MRA.";
      maintainers = [ "Kait Lam <k@rina.fyi>" ];
    };
  };
in
self
