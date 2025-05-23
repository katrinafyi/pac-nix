{ lib
, dockerTools
, bashInteractive
, writeText
, writeShellScriptBin
, devShellTools
, cacert
, storeDir ? builtins.storeDir
}:

# This file extracts streamNixShellImage from:
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/docker/default.nix
# This is needed because the original implementation does not let you
# customise the container image after it is constructed from the shell.
#
# We add a simple binary at a known location which executes commands
# in the context of the shell.

let
  inherit (dockerTools) streamLayeredImage binSh usrBinEnv fakeNss;
  inherit (devShellTools) valueToString;
  inherit (lib) optionalString;
in
{
  # This function streams a docker image that behaves like a nix-shell for a derivation
  # Docs: doc/build-helpers/images/dockertools.section.md
  # Tests: nixos/tests/docker-tools-nix-shell.nix
  streamNixShellImage =
    { drv
    , name ? drv.name + "-env"
    , tag ? null
    , uid ? 1000
    , gid ? 1000
    , homeDirectory ? "/build"
    , shell ? bashInteractive + "/bin/bash"
    , command ? null
    , run ? null
    , config ? {}
    }:
      assert lib.assertMsg (! (drv.drvAttrs.__structuredAttrs or false))
        "streamNixShellImage: Does not work with the derivation ${drv.name} because it uses __structuredAttrs";
      assert lib.assertMsg (command == null || run == null)
        "streamNixShellImage: Can't specify both command and run";
      let

        # A binary that calls the command to build the derivation
        builder = writeShellScriptBin "buildDerivation" ''
          exec ${lib.escapeShellArg (valueToString drv.drvAttrs.builder)} ${lib.escapeShellArgs (map valueToString drv.drvAttrs.args)}
        '';

        staticPath = "${dirOf shell}:${lib.makeBinPath [ builder ]}";

        # https://github.com/NixOS/nix/blob/2.8.0/src/nix-build/nix-build.cc#L493-L526
        rcfile = writeText "nix-shell-rc" ''
          unset PATH
          dontAddDisableDepTrack=1
          # TODO: https://github.com/NixOS/nix/blob/2.8.0/src/nix-build/nix-build.cc#L506
          [ -e $stdenv/setup ] && source $stdenv/setup
          PATH=${staticPath}:"$PATH"
          SHELL=${lib.escapeShellArg shell}
          BASH=${lib.escapeShellArg shell}
          set +e
          [ -n "$PS1" -a -z "$NIX_SHELL_PRESERVE_PROMPT" ] && PS1='\n\[\033[1;32m\][nix-shell:\w]\$\[\033[0m\] '
          if [ "$(type -t runHook)" = function ]; then
            runHook shellHook
          fi
          unset NIX_ENFORCE_PURITY
          shopt -u nullglob
          shopt -s execfail
          ${optionalString (command != null || run != null) ''
            ${optionalString (command != null) command}
            ${optionalString (run != null) run}
            exit
          ''}
        '';

        # https://github.com/NixOS/nix/blob/2.8.0/src/libstore/globals.hh#L464-L465
        sandboxBuildDir = "/build";

        drvEnv =
          devShellTools.unstructuredDerivationInputEnv { inherit (drv) drvAttrs; }
          // devShellTools.derivationOutputEnv { outputList = drv.outputs; outputMap = drv; };

        # Environment variables set in the image
        envVars = {

          # Root certificates for internet access
          SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
          NIX_SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

          # https://github.com/NixOS/nix/blob/2.8.0/src/libstore/build/local-derivation-goal.cc#L1027-L1030
          # PATH = "/path-not-set";
          # Allows calling bash and `buildDerivation` as the Cmd
          PATH = staticPath;

          # https://github.com/NixOS/nix/blob/2.8.0/src/libstore/build/local-derivation-goal.cc#L1032-L1038
          HOME = homeDirectory;

          # https://github.com/NixOS/nix/blob/2.8.0/src/libstore/build/local-derivation-goal.cc#L1040-L1044
          NIX_STORE = storeDir;

          # https://github.com/NixOS/nix/blob/2.8.0/src/libstore/build/local-derivation-goal.cc#L1046-L1047
          # TODO: Make configurable?
          NIX_BUILD_CORES = "1";

        } // drvEnv // {

          # https://github.com/NixOS/nix/blob/2.8.0/src/libstore/build/local-derivation-goal.cc#L1008-L1010
          NIX_BUILD_TOP = sandboxBuildDir;

          # https://github.com/NixOS/nix/blob/2.8.0/src/libstore/build/local-derivation-goal.cc#L1012-L1013
          TMPDIR = sandboxBuildDir;
          TEMPDIR = sandboxBuildDir;
          TMP = sandboxBuildDir;
          TEMP = sandboxBuildDir;

          # https://github.com/NixOS/nix/blob/2.8.0/src/libstore/build/local-derivation-goal.cc#L1015-L1019
          PWD = sandboxBuildDir;

          # https://github.com/NixOS/nix/blob/2.8.0/src/libstore/build/local-derivation-goal.cc#L1071-L1074
          # We don't set it here because the output here isn't handled in any special way
          # NIX_LOG_FD = "2";

          # https://github.com/NixOS/nix/blob/2.8.0/src/libstore/build/local-derivation-goal.cc#L1076-L1077
          TERM = "xterm-256color";
        };


      in streamLayeredImage {
        inherit name tag;
        contents = [
          binSh
          usrBinEnv
          (fakeNss.override {
            # Allows programs to look up the build user's home directory
            # https://github.com/NixOS/nix/blob/ffe155abd36366a870482625543f9bf924a58281/src/libstore/build/local-derivation-goal.cc#L906-L910
            # Slightly differs however: We use the passed-in homeDirectory instead of sandboxBuildDir.
            # We're doing this because it's arguably a bug in Nix that sandboxBuildDir is used here: https://github.com/NixOS/nix/issues/6379
            extraPasswdLines = [
              "nixbld:x:${toString uid}:${toString gid}:Build user:${homeDirectory}:/noshell"
            ];
            extraGroupLines = [
              "nixbld:!:${toString gid}:"
            ];
          })
        ];

        fakeRootCommands = ''
          # Effectively a single-user installation of Nix, giving the user full
          # control over the Nix store. Needed for building the derivation this
          # shell is for, but also in case one wants to use Nix inside the
          # image
          mkdir -p ./nix/{store,var/nix} ./etc/nix
          chown -R ${toString uid}:${toString gid} ./nix ./etc/nix

          # Gives the user control over the build directory
          mkdir -p .${sandboxBuildDir}
          chown -R ${toString uid}:${toString gid} .${sandboxBuildDir}
          chmod a+rwx ./${sandboxBuildDir}

          mkdir -p ./app
          chown -R ${toString uid}:${toString gid} ./app
          chmod a+rwx ./app

          mkdir -p ./tmp
          chmod a+rwx ./tmp

          cat <<'EOF' > ./usr/bin/_exec
          #!${shell}
          if [[ "$shell" != 1 ]]; then
            oldShellHook="$shellHook"
            unset shellHook
            export noDumpEnvVars=1
          fi
          source ${rcfile}
          exec "$@"
          EOF
          chmod +x ./usr/bin/_exec
        '';


        config = lib.recursiveUpdate {
          # Run this image as the given uid/gid
          User = "${toString uid}:${toString gid}";
          Cmd =
            # https://github.com/NixOS/nix/blob/2.8.0/src/nix-build/nix-build.cc#L185-L186
            # https://github.com/NixOS/nix/blob/2.8.0/src/nix-build/nix-build.cc#L534-L536
            if run == null
            then [ shell "--rcfile" rcfile ]
            else [ shell rcfile ];
          WorkingDir = sandboxBuildDir;
          Env = lib.mapAttrsToList (name: value: "${name}=${value}") envVars;
        } config;

      };
}
