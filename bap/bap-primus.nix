{ stdenv, testers, fetchFromGitHub, bap, makeBinaryWrapper, bap-primus }:
let
  _bap = bap.overrideAttrs (final: prev: {
    version = "2.6.0-alpha-unstable-2022-11-22";
    src = fetchFromGitHub {
      owner = "UQ-PAC";
      repo = "bap";
      rev = "acfdc1067afa847fa1eadac9700eae349434dc3b";
      sha256 = "sha256-FkfwMTbA9QS3vy4rs5Ua4egZg6/gQy3YzUG8xEyFo4A=";
    };
  });
in
stdenv.mkDerivation {
  pname = "bap-primus";
  version = _bap.version;

  # hack: pass through bap source for updating.
  src = _bap.src;

  buildInputs = [ _bap ];
  nativeBuildInputs = [ makeBinaryWrapper ];

  unpackPhase = ":";
  installPhase = ''
    mkdir -p $out/bin

    cd ${_bap}/bin
    for b in *; do 
      makeBinaryWrapper "$(pwd)/$b" $out/bin/$b-primus
    done
  '';

  passthru.tests.no-asli = testers.testBuildFailure (
    testers.testVersion {
      package = bap-primus;
      command = "bap-primus --help | grep asli";
      version = "asli-specs";
    }
  );
}
