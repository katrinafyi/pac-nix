{ lib
, runCommand
, python3
}:
{
  writePython3Application =
    { name, text ? "", src ? "", libraries ? [ ], runtimeInputs ? [ ], flakeIgnore ? [ ], flakeSelect ? [ "E9" "W2" ] }:
    let
      guard = throw "exactly one of `text` or `src` must be given to writePython3Application.";
      python = (if libraries != [ ] then python3.withPackages (_: libraries) else python3);
    in
    runCommand name
      { src = if (src == "") == (text == "") then guard else src; }

      ''
        mkdir -p $out/bin
        py=$out/bin/${name}

        echo '#!${python.interpreter}' >> $py
        p='${lib.makeBinPath runtimeInputs}'
        [[ -n "$p" ]] && p=":$p"
        echo "import os; os.environ['PATH'] += r'$p'; del os" >> $py
        if [[ -n "$src" ]]; then
          cat $src >> $py
        else
          echo '${text}' >> $py
        fi

        chmod +x $py
      '';
}
