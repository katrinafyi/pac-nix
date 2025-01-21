{
  buildDunePackage,
  cohttp,
}:

buildDunePackage {
  pname = "http";
  inherit (cohttp)
    version
    src
    ;

  duneVersion = "3";

  buildInputs = [ ];

  doCheck = false;

  propagatedBuildInputs = [ ];

  meta = cohttp.meta // {
    description = "Type definitions of HTTP essentials";
  };
}
