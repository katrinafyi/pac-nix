{ lib
, fetchFromGitHub
, pkgs
, asli
, ocamlPackages
, bisect_ppx
, ppx_inline_test
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
  buildInputs = [ bisect_ppx ];
  nativeBuildInputs = [ ];
  propagatedBuildInputs = [ ppx_inline_test ];

  meta = {
    homepage = "https://github.com/mimoo/hexstring";
    description = "An ocaml library to encode to and decode from hexadecimal strings";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
