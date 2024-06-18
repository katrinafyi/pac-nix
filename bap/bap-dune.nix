{ lib
, fetchFromGitHub 
, buildDunePackage
, which, linenoise, ounit, ppx_bitstring, z3
, utop, libxml2, ncurses
, bitstring, camlzip, cmdliner, ppx_bap, core_kernel
, ezjsonm, fileutils, mmap, lwt, ocamlgraph, ocurl
, re, uri, zarith, piqi, parsexp, piqi-ocaml, uuidm
, frontc, yojson, ocamlbuild, dune-configurator, dune-site
, llvmPackages
, ocaml_oasis
, breakpointHook 

}:

buildDunePackage {
  pname = "bap";
  version = "boop";

  minimalOCamlVersion = "4.09";

  src = fetchFromGitHub {
    owner = "BinaryAnalysisPlatform";
    repo = "bap";
    rev = "95e81738c440fbc928a627e4b5ab3cccfded66e2";
    hash = "sha256-gogcwqK7EK4Fs4HiCXKxWeFpJ1vJlJupMtJu+8M9kjs=";
  };

  nativeBuildInputs = [ which piqi-ocaml ocaml_oasis ocamlbuild ];

  buildInputs = [ linenoise
                  ounit
                  ppx_bitstring
                  z3
                  utop libxml2 ncurses ocamlbuild dune-configurator dune-site ];

  propagatedBuildInputs = [ bitstring camlzip cmdliner ppx_bap core_kernel ezjsonm fileutils mmap lwt ocamlgraph ocurl re uri zarith piqi parsexp
                            piqi-ocaml uuidm frontc yojson ocamlbuild ];

  env = {
    BAP_DEBUG = 1;
  };

  configureScript = ":";
  # configureFlags = [ "--enable-everything" "--disable-ida" "--disable-ghidra" "--with-llvm-config=${llvmPackages.libllvm.dev}/bin/llvm-config" ];
  dontDetectOcamlConflicts = true;

  postPatch = ''
    substituteAllInPlace lib/bap_llvm/config/llvm_configurator.ml --replace -lcurses -lncurses

    mkdir -p path-tmp
    ln -s ${lib.getExe piqi-ocaml} path-tmp/piqi
    export PATH=$PATH:$(pwd)/path-tmp
  '';

  buildPhase = ''
    runHook preBuild
    dune build -j $NIX_BUILD_CORES
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    dune install --prefix $out --libdir $OCAMLFIND_DESTDIR \
      --docdir $out/share/doc --mandir $out/share/man
    runHook postInstall
  '';

  meta = {
    description = "Platform for binary analysis. It is written in OCaml, but can be used from other languages";
    homepage = "https://github.com/BinaryAnalysisPlatform/bap/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.katrinafyi ];
    mainProgram = "bap";
  };
}
