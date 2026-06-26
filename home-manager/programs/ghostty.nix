# Ghostty terminal config (GPU binary from system-setup apt/PPA; not Nix).

{ ... }:

{
  home.file.".config/ghostty/config".source = ../configs/ghostty/config;
}
