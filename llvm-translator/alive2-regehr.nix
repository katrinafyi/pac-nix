{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-01-19";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "eb44d0d2f441834acd453c27276063e97ddf7b95";
    hash = "sha256-b0leZQO7pOpI+//QAymagwE1SAzapE5p2c+ALttToEk=";
  };

})
