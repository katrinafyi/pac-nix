{ lib
, buildEmscriptenPackage 
, fetchFromGitHub
}:

buildEmscriptenPackage {
  pname = "keystonejs";
  version = "0";

  src = fetchFromGitHub {
    owner = "ailrst";
    repo = "keystone.js";
    rev = "efe179a31bf5cd569c017b8e3db333851cb34a03";
    hash = "sha256-dxlkma6igPOeuUYiesJQhxE6Uij7UOPTf6LyJDzi0U0=";
  };

  meta = {
    homepage = "https://github.com/ailrst/keystone.js";
    description = "Keystone assembler framework for JavaScript (forked)";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
