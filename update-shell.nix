{ mkShell
, update
}:
mkShell {
  name = "update-py-shell";
  inputsFrom = [
    update
  ];

  meta = {
    description = "Shell for update.py";
  };
}
