{ dockerTools
, gtirb-semantics
, buildEnv
}:

dockerTools.streamLayeredImage {
  name = "ghcr.io/uq-pac/gtirb-semantics-server";
  tag = "latest";
  created = "now";
  mtime = "now";

  contents = buildEnv {
    name = "gtirb-semantics-image-root";
    paths = [ gtirb-semantics dockerTools.binSh ];
    pathsToLink = [ "/bin" ];
  };

  fakeRootCommands = ''
    mkdir -p ./data
  '';

  config = {
    Cmd = [ "/bin/gtirb-semantics" "--serve" ];
    WorkingDir = "/data";
    Volumes = {
      "/data" = { };
    };
  };
}
