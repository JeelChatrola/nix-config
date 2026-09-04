{ host, lib, pkgs, ... }:

{
  imports = [ ../programs/ghostty.nix ]
    ++ lib.optionals (lib.hasSuffix "-linux" host.system) [ ../programs/rofi.nix ];

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
