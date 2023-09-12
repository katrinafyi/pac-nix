{ fetchFromGitHub, ocamlPackages }:
  ocamlPackages.bap.overrideAttrs rec {
    version = "acfdc1067afa847fa1eadac9700eae349434dc3b";
    src = fetchFromGitHub {
      owner = "UQ-PAC";
      repo = "bap";
      rev = "acfdc1067afa847fa1eadac9700eae349434dc3b";
      sha256 = "sha256-FkfwMTbA9QS3vy4rs5Ua4egZg6/gQy3YzUG8xEyFo4A=";
    };
  }
