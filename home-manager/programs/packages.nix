# Packages configuration
# This file contains all packages installed by Home Manager.

{
  lib,
  pkgs,
  pkgsUnstable,
  userProfile,
  ...
}:
let
  nixRefresh = pkgs.writeShellScriptBin "nix-refresh" ''
    exec ${pkgs.bash}/bin/bash "${userProfile.nixConfigDir}/deploy.sh" "$@"
  '';

  workflowHelp = pkgs.writeShellApplication {
    name = "workflow-help";
    runtimeInputs = with pkgs; [
      coreutils
      fzf
    ];
    text = builtins.readFile ../../bin/workflow-help;
  };

  commonPackages = with pkgs; [
    # System utilities
    tree
    htop
    ctop
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

    # Productivity and knowledge tools
    navi
    tldr
    buku
    numbat
    obsidian

    # Data and document tools
    magika
    python313Packages.markitdown

    # LLM utilities
    pkgsUnstable.llmfit

    # Core development tools
    curl
    wget
    git
    git-lfs
    nodejs_24
    zsh
    zoxide
    broot
    nh
    tmux
    sesh
    nixRefresh
    workflowHelp

    # Docker/container CLIs. On macOS these are client tools; Docker Desktop/Colima owns the daemon.
    docker
    docker-compose
    lazydocker
    dive

    # Git tools
    lazygit
    gh

    # C/C++ development
    bear
    ccache
    cmake
    ninja
    gnumake
    pkg-config
    lldb
    clang-tools

    # Python development
    python3
    python3Packages.pip
    python3Packages.virtualenv
    uv
    ruff

    # Networking/security
    openssh
    tailscale

    # Fonts
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg

    # Text editors and file utilities
    nano
    unzip
    zip
    gzip
    which
    file
    less
    more

    # Multimedia/media tools
    ffmpeg
  ];

  linuxPackages = with pkgs; [
    xclip
    gcc
    gdb
    man-pages
    man-db
  ];
in
{
  home.packages = commonPackages ++ lib.optionals pkgs.stdenv.isLinux linuxPackages;
}
