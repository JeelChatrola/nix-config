# lf file manager: config only (package from packages.nix)

{ ... }:

{
  home.file.".config/lf/lfrc".source = ../configs/lf/lfrc;

  home.file.".config/lf/preview" = {
    source = ../configs/lf/preview;
    executable = true;
  };
}
