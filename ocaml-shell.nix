{ mkShell
, ocamlPackages
, asli
, gtirb-semantics
}:
mkShell rec {
  packages = with ocamlPackages; [ ocaml-lsp ocamlformat_0_26_0 ];
  inputsFrom = [ asli gtirb-semantics ];
  shellHook = ''
    echo
    echo == pac-nix/OCaml development shell ==
    echo
    echo 'with dependencies from:' ${toString (map (x: x.name) inputsFrom)}
    echo
    echo 'start your editor from this shell'
    echo 'use `ocamlfind list` to list installed packages'
    echo 'use `opam install` to install extra packages, if needed'
    echo
  '';
}
