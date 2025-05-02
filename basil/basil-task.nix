{ lib
, stdenv
, makeWrapper
, go-task
, basil
, compiler-explorer
}:

let
  bins = [

  ];
in stdenv.mkDerivation (self: {
  pname = "basil-task";

  inherit (compiler-explorer) version src;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ ];

  preBuild = ''
    mkdir -p $out/bin
    cd basil-task

    cp basil-task.sh basil-task
    cp -v mutex.sh basil-task Taskfile.yml $out/bin

    wrapProgram $out/bin/basil-task \
      --prefix PATH : $out/bin:${lib.makeBinPath []}
  '';
})
