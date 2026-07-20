{ lib, pkgs, ... }:

{
  imports = [ ../programs/ghostty.nix ];

  fonts.fontconfig.enable = lib.mkIf pkgs.stdenv.isLinux true;
  home.sessionVariables.BROWSER = "firefox";

  home.packages = with pkgs; [
    obsidian
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    firefox
    xclip
  ];
}
