# Docker images produced by Nix

Nix can be used to produce lightweight Docker images.
Unlike Docker images built in the usual way based on an operating
system, the containers created by Nix are truly minimal -
they contain only the files provided and their necessary dependencies.

This page describes the high-level usage of Docker images produced by Nix,
then goes into more technical details.

## Godbolt Docker image

The Godbolt Docker image bundles the compiler explorer interface along
with the Basil toolchain and its dependencies
into a single ready-to-use command.

Requirements:
- Nix
- Docker

This command scripts the process of building
and starting the required containers.
```
NIXPKGS_ALLOW_INSECURE=1 nix run github:katrinafyi/pac-nix#start-godbolt --impure -- up
```
After some time, this will start running the
godbolt interface at http://localhost:10240.

### Details

docker-compose

docker images

## Building Docker images with Nix

streamlayered image. saves nix store space

## Defining Docker images

from nix shell

directly with buildenv
