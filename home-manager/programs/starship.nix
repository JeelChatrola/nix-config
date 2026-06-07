# Starship — official Gruvbox Rainbow preset (https://starship.rs/presets/gruvbox-rainbow)

{ ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ../configs/starship/gruvbox-rainbow.toml);
  };
}
