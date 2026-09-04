{ pkgs, ... }:

let
  nixRefresh = pkgs.writeShellScriptBin "nix-refresh" ''
    config_dir="''${NIX_CONFIG_DIR:-$HOME/nix-config}"
    exec ${pkgs.bash}/bin/bash "$config_dir/deploy.sh" "$@"
  '';

  workflowHelp = pkgs.writeShellApplication {
    name = "workflow-help";
    runtimeInputs = with pkgs; [
      coreutils
      fzf
    ];
    text = builtins.readFile ../../bin/workflow-help;
  };
in
{
  imports = [
    ../programs/git.nix
    ../programs/zsh.nix
    ../programs/tmux.nix
    ../programs/ssh.nix
    ../programs/fzf.nix
    ../programs/oh-my-posh.nix
    ../programs/neovim.nix
    ../programs/lf.nix
  ];

  home.packages = with pkgs; [
    tree
    htop
    ripgrep
    fd
    bat
    eza
    fzf
    jq
    yq-go
    fastfetch
    rsync
    rclone
    lf
    gping
    navi
    tldr
    buku
    numbat
    curl
    wget
    git
    zsh
    zoxide
    broot
    nh
    tmux
    sesh
    openssh
    nano
    unzip
    zip
    gzip
    which
    file
    less
    more
    nixRefresh
    workflowHelp
  ];
}
