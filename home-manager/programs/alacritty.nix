# Alacritty: manage config only (use distro / non-Nix binary for GPU integration).
# We avoid programs.alacritty here so Nix does not install its own alacritty build.

{ ... }:

{
  home.file.".config/alacritty/alacritty.toml".source = ../configs/alacritty/alacritty.toml;
}
