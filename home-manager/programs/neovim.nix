{ capabilities, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = builtins.elem "development" capabilities;
    withPython3 = builtins.elem "development" capabilities;
    withRuby = false;
    initLua = builtins.readFile ../configs/nvim/init.lua;
    extraPackages = with pkgs; [
      curl
      fd
      git
      ripgrep
      unzip
    ] ++ lib.optionals (builtins.elem "development" capabilities) [
      gnumake
      lazygit
      tree-sitter
    ] ++ lib.optionals (builtins.elem "development" capabilities && pkgs.stdenv.isLinux) [
      gcc
    ];
  };

  # Update Lazy's lockfile in this repository before deploying; deployed config is immutable.
  xdg.configFile."nvim/lua".source = ../configs/nvim/lua;
  xdg.configFile."nvim/lazy-lock.json".source = ../configs/nvim/lazy-lock.json;
}
