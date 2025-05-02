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
    mkdir -p $out/bin $out/lib/basil-task
    cd basil-task

    cp basil-task.sh basil-task
    cp -v mutex.sh basil-task.sh Taskfile.yml $out/lib/basil-task

    makeWrapper $out/lib/basil-task/basil-task.sh $out/bin/basil-task \
      --prefix PATH : $out/bin:${lib.makeBinPath []}
  '';
})
