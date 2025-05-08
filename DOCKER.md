# Docker images produced by Nix

Nix can be used to produce lightweight Docker images.
Usually, Docker images built with a Dockerfile in the usual way
will be based on an operating system.
When packaging applications, this leads to a bigger image by
including unnecessary OS programs, and weakens reproducibility
by relying on fetching updated packages from the internet.
Unlike Docker images built in this way,
the containers created by Nix are truly minimal -
they contain only the files provided and their necessary dependencies -
and they provide a fixed version of all included software.

This page describes the high-level usage of Docker images produced by Nix,
then goes into more technical details.

## Godbolt Docker image

The Godbolt Docker image bundles the compiler explorer interface along
with the Basil toolchain and makes it available through a single
`start-godbolt` command.

Requirements:
- Nix (see [README](https://github.com/katrinafyi/pac-nix/?tab=readme-ov-file#usage))
- [Podman](https://podman.io/) (or Docker)

To **load** the Docker images onto your system, use this command:
```
NIXPKGS_ALLOW_INSECURE=1 nix run github:katrinafyi/pac-nix#start-godbolt --impure -- config
```
This will download the Nix packages for Godbolt, Basil, aarch64 GCC/Clang, and other
required tools.
When finished, it will print the basil-godbolt container config.

Then, to **run** the Godbolt server, use this command
(the same command as above, but with `up` at the end in place of `config`):
```
NIXPKGS_ALLOW_INSECURE=1 nix run github:katrinafyi/pac-nix#start-godbolt --impure -- up
```
After printing some output, this will start running the Godbolt interface at http://localhost:10240.
The gtirb-semantics server should also appear in the log with the message
"Initialised lifter environment".
To stop the server, simply Ctrl+C the console.

### Details

The `start-godbolt` script is a thin wrapper around docker-compose, which is a framework
for managing multiple docker containers.
Here, we have two containers: one for Godbolt, and one for the long-lived gtirb-semantics server
(to speed up semantics). You can inspect the docker-compose config using
`nix build .#godbolt-docker-compose` and customise it if needed.

On the first run, or when the containers have changed, the `start-godbolt` command
will also load the Docker images from Nix into the system's Docker image list.
If needed, you can replicate these steps manually with:
```
nix build .#basil-tools-docker && ./result | podman image load
nix build .#basil-godbolt-docker && ./result | podman image load
```

Note that the Nix packages ending in `-docker` actually produce a script which
writes the Docker image to stdout, instead of directly producing an image file.
This allows the image to be generated "on-the-fly" from the pre-existing Nix packages,
and avoids the need for multiple copies of the same package in different Nix locations.

## Defining Docker images

Nixpkgs has a number of functions to produce Docker images. These are grouped under the dockerTools
namespace ([manual reference](https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-dockerTools)).

In pac-nix, we make use of two functions:
- [streamNixShellImage](https://nixos.org/manual/nixpkgs/stable/#ssec-pkgs-dockerTools-streamNixShellImage)
  converts a Nix shell into a Docker image. This is used for the Basil and Godbolt containers, as it
  effectively exports the Nix build sandbox environment into a Docker container.
  This is well-suited to the use case where we need to consistently compile code from source.
- [streamLayeredImage](https://nixos.org/manual/nixpkgs/stable/#ssec-pkgs-dockerTools-streamLayeredImage)
  simply bundles certain Nix packages and their dependencies into a Docker image.
  This is used for the gtirb-semantics container which only requires the gtirb-semantics program.
