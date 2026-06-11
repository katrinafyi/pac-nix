{ python3Packages
, gtirb
}:

python3Packages.buildPythonPackage {
  pname = "gtirb";
  version = gtirb.version;

  src = gtirb.python;
  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  buildInputs = with python3Packages; [ pip ];
  propagatedBuildInputs = with python3Packages; [ networkx typing-extensions sortedcontainers intervaltree protobuf ];

  preConfigure = ''
    cd python
    substituteInPlace setup.py \
      --replace 'protobuf<=3.20.1' 'protobuf'
  '';

  dontUseSetuptoolsCheck = true;
  postInstallCheck = ''
    python3 -m unittest discover tests
  '';
}
