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
    version = "unstable-2023-09-18";

    minimalOCamlVersion = "4.09";

    src = fetchFromGitHub {
      owner = "UQ-PAC";
      repo = "aslp";
      rev = "758815e22144f6645839dd81b83d235fab53d3ee";
      sha256 = "sha256-1jRxKCMOvmVy7N4vMq8kt7HPOavfwDNWi7yBk8hcrDs=";
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
