# Ghostty terminal config (GPU binary from system-setup or nix profile).

{ ... }:

{
  home.file.".config/ghostty/config".source = ../configs/ghostty/config;
}
