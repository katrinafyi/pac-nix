{ pkgs ? import ./pkgs.nix { } }:
pkgs.mkShell {
  packages =
    (with pkgs; [ ocaml ott ocamlformat ]) ++
    (with pkgs.ocamlPackages; [ merlin ocaml-lsp odoc ]);

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
