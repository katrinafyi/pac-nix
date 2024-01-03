{ lib,
  fetchFromGitHub,
  ocaml,
  pkgs,
  asli,
  ocamlPackages
}:

ocamlPackages.buildDunePackage rec {
  pname = "hexstring";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "mimoo";
    repo = "hexstring";
    rev = "0.2.1";
    sha256 = "sha256-6TL+5Z3dMqDYMaySUG4pCz2UiASMdm4wOlAW6H4Ksp4=";
  };

  checkInputs = [ ];
  buildInputs = (with ocamlPackages; [ bisect_ppx ]);
  nativeBuildInputs = [];
  propagatedBuildInputs = (with ocamlPackages; [ ppx_inline_test ]);
  doCheck = lib.versionAtLeast ocaml.version "4.09";

  meta = {
    homepage = "https://github.com/mimoo/hexstring";
    description = "An ocaml library to encode to and decode from hexadecimal strings";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
