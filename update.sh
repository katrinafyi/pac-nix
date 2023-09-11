#! /usr/bin/env nix-shell
#! nix-shell -i bash --packages nix-update jq curl cacert git nix vim --pure --keep GITHUB_TOKEN

# updates the revision hash for each upstream package.
# for each updated package, this checks the derivation can be built
# then commits its results.

set -e

PKGS=./pkgs.nix
TMP=$(mktemp)

curl() {
  if ! [[ -z "$GITHUB_TOKEN" ]]; then
    command curl --header "Authorization: Bearer $GITHUB_TOKEN" "$@"
  else
    command curl "$@"
  fi
}

update-github() {
  attr="$1"  # pkgs.nix package name to update
  repo="$2"  # username/repository of upstream repository
  branch="$3"  # branch (if unset, uses repo's default branch)

  REPO_API="https://api.github.com/repos/$repo"

  if [[ -z "$branch" ]]; then
    branch=$(curl "$REPO_API" | jq -r .default_branch)
  fi

  COMMITS_API="https://api.github.com/repos/$repo/commits/$branch"
  latest=$(curl "$COMMITS_API" | jq -r .sha)

  nix-update -f "$PKGS" $attr --version $latest --commit --build
}

test-build() {
  pkg="$1"
  nix-build $PKGS -A $pkg --no-out-link
}

update-github asli UQ-PAC/aslp
test-build aslp

update-github bap-asli-plugin UQ-PAC/bap-asli-plugin
test-build bap-aslp

update-github basil UQ-PAC/bil-to-boogie-translator

rm -fv ./result
