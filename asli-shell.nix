{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  packages = [ pkgs.ocaml pkgs.ott pkgs.ocamlPackages.merlin pkgs.ocamlPackages.ocaml-lsp pkgs.ocamlformat ];

  inputsFrom = [ pkgs.asli ];

  shellHook = ''
    export DEBUG=1
    export OPAMSWITCH=nix-shell-asli
    CAML_LD_PREV=$CAML_LD_LIBRARY_PATH

    #opam init --no-setup
    #opam switch create $OPAMSWITCH ocaml-system
    #eval $(opam env)

    export ASLI_OTT=${pkgs.ott}/share/ott

    #export CAML_LD_LIBRARY_PATH=$CAML_LD_PREV:$CAML_LD_LIBRARY_PATH
  '';

  meta = {
    description = "Shell for developing ASLi.";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
