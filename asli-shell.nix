{ pkgs ? import ./pkgs.nix {} }:
pkgs.mkShell {
  packages = [ pkgs.ocaml pkgs.ott pkgs.ocamlPackages.merlin pkgs.ocamlPackages.ocaml-lsp pkgs.ocamlformat ];

  inputsFrom = [ pkgs.asli ];

  # run to initialise the shell.
  shellHook = ''
    export ASLI_OTT=${pkgs.ott}/share/ott
  '';

  meta = {
    description = "Shell for developing ASLi.";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
