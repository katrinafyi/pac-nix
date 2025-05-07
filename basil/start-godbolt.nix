{ writeShellScriptBin
, gtirb-semantics-server-docker
, basil-godbolt-docker
, godbolt-docker-compose
}:

writeShellScriptBin "start-godbolt" ''
  DOCKER="''${DOCKER:-docker}"

  set -eu

  mkdir -p /tmp/start-godbolt
  cd /tmp/start-godbolt

  s="${basil-godbolt-docker} ${gtirb-semantics-server-docker}"

  : >> hash
  if [[ "$(cat hash)" == "$s" ]]; then
    echo "$0: skipping image load due to matching hash in" "$(realpath hash)" >&2
    set -x
  else
    set -x
    ${basil-godbolt-docker} | $DOCKER image load
    ${gtirb-semantics-server-docker} | $DOCKER image load
    echo "$s" > hash
  fi
  exec $DOCKER compose -f ${godbolt-docker-compose} "$@"
''
