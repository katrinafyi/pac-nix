{ python3Packages
, fetchFromGitHub
}:

python3Packages.buildPythonPackage {
  pname = "retypd";
  version = "unstable-2023-04-10";

  src = fetchFromGitHub {
    owner = "katrinafyi";
    repo = "retypd";
    rev = "90f27db479d980bed30ac5330258eaf746ebf242";
    hash = "sha256-rSl4i+ivo4onFTt8Q+tWAsBJoEy5Xy+BHJ1INH0xrWw=";
  };

  # fetchFromGitHub {
  #   owner = "GrammaTech";
  #   repo = "retypd";
  #   rev = "8f7f72be9a567731bb82636cc91d70a3551050bf";
  #   hash = "sha256-N60e0VOUCMUPruMGBF3hHVMqeWiWrLFnAZY+CLzLyPs=";
  # };

  nativeBuildInputs = with python3Packages; [ pip ];
  buildInputs = with python3Packages; [ pyformlang graphviz networkx tqdm ];
}
