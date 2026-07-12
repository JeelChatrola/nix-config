{ config, pkgs, userProfile, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = false;
    initLua = builtins.readFile ../configs/nvim/init.lua;
    extraPackages = with pkgs; [
      curl
      fd
      gcc
      git
      gnumake
      lazygit
      ripgrep
      tree-sitter
      unzip
    ];
  };

  # AstroNvim configuration and lockfile stay writable for Lazy updates.
  xdg.configFile."nvim/lua" = {
    source = config.lib.file.mkOutOfStoreSymlink "${userProfile.nixConfigDir}/home-manager/configs/nvim/lua";
    force = true;
  };
  xdg.configFile."nvim/lazy-lock.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${userProfile.nixConfigDir}/home-manager/configs/nvim/lazy-lock.json";
    force = true;
  };
}
