{ stdenv, lib, ocaml, findlib, zarith, z3 }:

if lib.versionOlder ocaml.version "4.07"
then throw "z3 is not available for OCaml ${ocaml.version}"
else

let z3-with-ocaml1 = z3.override {
  ocamlBindings = true;
  inherit ocaml findlib zarith;
}; in

let z3-with-ocaml = z3-with-ocaml1.overrideAttrs (p: {
  postInstall = p.postInstall + ''
    ln -sf $lib/lib/libz3${stdenv.hostPlatform.extensions.sharedLibrary} $OCAMLFIND_DESTDIR/stublibs/libz3${stdenv.hostPlatform.extensions.sharedLibrary} 
  '';
}); in

stdenv.mkDerivation {

  pname = "ocaml${ocaml.version}-z3";
  inherit (z3-with-ocaml) version;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $OCAMLFIND_DESTDIR
    cp -r ${z3-with-ocaml.ocaml}/lib/ocaml/${ocaml.version}/site-lib/stublibs $OCAMLFIND_DESTDIR
    cp -r ${z3-with-ocaml.ocaml}/lib/ocaml/${ocaml.version}/site-lib/Z3 $OCAMLFIND_DESTDIR/z3
    runHook postInstall
  '';

  nativeBuildInputs = [ findlib ];
  propagatedBuildInputs = [ zarith ];

  strictDeps = true;

  meta = z3.meta // {
    description = "Z3 Theorem Prover (OCaml API)";
  };
}
