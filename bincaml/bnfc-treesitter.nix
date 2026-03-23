{ lib
, haskell
, haskellPackages
, fetchFromGitHub
}:

lib.pipe haskellPackages.BNFC [
  (haskell.lib.compose.overrideSrc {
    src = fetchFromGitHub {
      owner = "rina-forks";
      repo = "bnfc";
      rev = "6c3bbc2ec0710fcc9f122ec4303c2cdf46ce33c4";
      hash = "sha256-R4owoA3NKQIGk6RI5A10KlkIFOEna+rRQ0Ir4WHZVYE=";
    };
    version = "0-unstable-2026-02-23";
  })
  (haskell.lib.compose.overrideCabal (_: {
    postPatch = "cd source";
  }))
]
