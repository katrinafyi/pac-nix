{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation {
  pname = "unrandom";
  version = "unstable-2024-02-20";

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "unrandom";
    rev = "2b2f24fc37ea4f13bbb01e05559ed54a492fc829";
    hash = "sha256-c/4IfYTGRnaBCPbzXzBBGbswpBHaYhJmTU6fmh83kXc=";
  };

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/lib
    cp -v *.so $out/lib

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/katrinafyi/unrandom";
    description = "determinism!";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
