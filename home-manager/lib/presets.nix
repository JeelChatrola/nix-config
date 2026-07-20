{ lib }:

let
  capabilities = [
    "base"
    "desktop"
    "development"
    "containers"
    "ai"
  ];

  presets = {
    base = [ "base" ];
    personal = [
      "base"
      "desktop"
    ];
    workstation = [
      "base"
      "desktop"
      "development"
      "containers"
    ];
    server = [
      "base"
      "containers"
    ];
  };

  validate = names:
    let
      unknown = lib.filter (name: !(builtins.elem name capabilities)) names;
    in
    if unknown == [ ] then names else throw "Unknown capabilities: ${lib.concatStringsSep ", " unknown}";
in
{
  inherit capabilities presets;

  resolve =
    {
      preset,
      additions ? [ ],
      removals ? [ ],
    }:
    let
      selected = presets.${preset} or (throw "Unknown preset: ${preset}");
      requested = lib.unique (validate (selected ++ additions));
      excluded = validate removals;
    in
    lib.filter (name: !(builtins.elem name excluded)) requested;
}
