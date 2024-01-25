final: prev:
{
  makePythonPth =
    { python, ... } @ pythonPackages: name: runtimeInputs:
    final.runCommand "${name}-runtimeinputs"
      {
        passthru = {
          pythonModule = python;
          requiredPythonModules = pythonPackages.requiredPythonModules [ ];
        };
      }
      ''
        d=$out/${python.sitePackages}
        mkdir -p $d
        printf '%s; ' \
          'import os' \
          'd=r"""${final.lib.makeBinPath runtimeInputs}"""' \
          'os.environ["PATH"] += (os.pathsep+d) if d else ""' \
          > $d/${name}-runtimeinputs.pth
      '';


  writePython3Application =
    { name
    , text ? ""
    , src ? ""
    , libraries ? [ ]
    , runtimeInputs ? [ ]
    , pythonPackages ? final.python3Packages
    , flakeIgnore ? [ ]
    , flakeSelect ? [ "E9" "W2" ]
    }:
    let
      guard = throw "exactly one of `text` or `src` must be given to writePython3Application.";
      python = pythonPackages.python;
      env =
        if libraries != [ ] || runtimeInputs != [ ]
        then python.withPackages (_: libraries ++ [ pth ])
        else python;

      pth = final.makePythonPth pythonPackages name runtimeInputs;
    in
    final.runCommand
      name
      { src = if (src == "") == (text == "") then guard else src; }
      ''
        mkdir -p $out/bin
        py=$out/bin/${name}

        echo '#!${env.interpreter}' > $py
        chmod +x $py

        if [[ -n "$src" ]]; then
          cat $src >> $py
        else
          echo ${final.lib.escapeShellArgs [text]} >> $py
        fi
      '';
}
