#! /usr/bin/env nix-shell
#! nix-shell -i bash --packages nix-update curl jq cacert git nix vim --pure --keep GITHUB_TOKEN --keep NIX_PATH

# updates the revision hash for each upstream package.
# for each updated package, this checks the derivation can be built
# then commits its results.

set -e

case "$1" in
  check)
    MODE=check
    ;;
  upgrade)
    MODE=upgrade
    ;;
  *)
    echo "$0: missing required argument" >&2
    echo "Usage: $0 [ check | upgrade ]" >&2
    exit 1
    ;;
esac

do-upgrade() {
  [[ $MODE == upgrade ]]
}

PKGS=./pkgs.nix
TMP=$(mktemp)

PID=$$
curl() {
  TMP=$(mktemp)
  if ! [[ -z "$GITHUB_TOKEN" ]]; then
    command curl --fail-with-body -s --header "Authorization: Bearer $GITHUB_TOKEN" "$@" >$TMP
  else
    command curl --fail-with-body -s "$@" >$TMP
  fi
  EXIT=$?
  if [[ $EXIT != 0 ]]; then
    echo "::error title=curl failure ($EXIT)::curl $@" >&2
    cat $TMP >&2
    kill -ABRT $PID
  else 
    cat $TMP
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

  if do-upgrade; then
    nix-update -f "$PKGS" $attr --version branch=$branch --commit --build
  else
    current=$(nix-instantiate --eval -E "(import ./$PKGS {}).$attr.src.rev" | jq -r)
    COMPARE="https://api.github.com/repos/$repo/compare/$current...$branch"
    compare=$(curl "$COMPARE")
    
    result=$(echo "$compare" | jq '{ html_url, status, ahead_by, behind_by, total_commits }')
    echo "$compare" | jq '{ html_url, status, ahead_by, behind_by, total_commits }' 

    if [[ $(echo "$compare" | jq .total_commits) != 0 ]]; then
      echo "::warning title=Package outdated: $attr::$attr differs by $(echo "$compare" | jq .total_commits) commits from $branch ($(echo "$compare" | jq .permalink_url -r))"
    else
      echo "::notice   title=Package current: $attr::$attr differs by $(echo "$compare" | jq .total_commits) commits from $branch ($(echo "$compare" | jq .permalink_url -r))"
    fi
  fi
}

test-build() {
  pkg="$1"
  if do-upgrade; then
    nix-build $PKGS -A $pkg --no-out-link
  fi
}

if do-upgrade; then
  echo "Performing upgrade..."
else
  echo "Checking for upstream updates..."
fi

update-github asli UQ-PAC/aslp
test-build aslp

update-github bap-asli-plugin UQ-PAC/bap-asli-plugin
test-build bap-aslp

update-github basil UQ-PAC/bil-to-boogie-translator

update-github bap-uq-pac UQ-PAC/bap aarch64-pull-request-2

rm -fv ./result
