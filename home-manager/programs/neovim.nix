{ config, pkgs, userProfile, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = false;
    initLua = ''
      require("config.lazy")
    '';
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

  # Lazy.nvim updates lazy-lock.json, so keep the source checkout writable.
  xdg.configFile."nvim/lua" = {
    source = config.lib.file.mkOutOfStoreSymlink "${userProfile.nixConfigDir}/home-manager/configs/nvim/lua";
    force = true;
  };
  xdg.configFile."nvim/lazy-lock.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${userProfile.nixConfigDir}/home-manager/configs/nvim/lazy-lock.json";
    force = true;
  };
}
