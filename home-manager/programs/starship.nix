# Starship — official Tokyo Night preset (https://starship.rs/presets/tokyo-night)

{ ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ../configs/starship/tokyo-night.toml);
  };
}
