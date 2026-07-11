# Packages configuration
# This file contains all the packages you want to install

{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  userProfile,
  ...
}:
let
  projectRoots = lib.concatStringsSep ":" userProfile.projectRoots;
  nixRefresh = pkgs.writeShellScriptBin "nix-refresh" ''
    exec ${pkgs.bash}/bin/bash "${userProfile.nixConfigDir}/deploy.sh" "$@"
  '';
  tmuxProject = pkgs.writeShellApplication {
    name = "tmux-project";
    runtimeInputs = with pkgs; [
      coreutils
      fd
      findutils
      fzf
      git
      gnused
      tmux
      zoxide
    ];
    text = ''
      export PROJECT_ROOTS="''${PROJECT_ROOTS:-${projectRoots}}"
      ${builtins.readFile ../../bin/tmux-project}
    '';
  };
in
{
  home.packages = with pkgs; [    
    # =============================================================================
    # SYSTEM UTILITIES
    # =============================================================================
    tree              # Display directory structure as a tree
    htop              # Interactive process viewer (better than top)
    # btop              # Modern resource monitor (better than htop) - using apt version instead (GPU detection works)
    ctop              # Container metrics and monitoring (like top for containers)
    ripgrep           # Fast grep alternative (search file contents)
    fd                # Fast find alternative (search file names)
    bat               # Cat with syntax highlighting and git integration
    eza               # Modern ls replacement with colors and icons
    fzf               # Fuzzy finder for command-line
    jq                # JSON processor and query tool
    yq-go             # YAML processor (like jq but for YAML)
    fastfetch         # System information display tool
    xclip             # X11 clipboard (zsh copy/cut widgets)
    rsync             # Remote file synchronization
    rclone            # Cloud storage management (sync, copy, mount cloud storage)
    lf                # Terminal file manager (fast, simple, vi-like)
    gping             # Ping with a graph (visual network latency)
    
    # =============================================================================
    # PRODUCTIVITY & KNOWLEDGE TOOLS
    # =============================================================================
    navi              # Interactive cheat sheet tool (command examples)
    tldr              # Simplified man pages (community-driven examples)
    buku              # Powerful bookmark manager for URLs

    # =============================================================================
    # DATA & DOCUMENT TOOLS
    # =============================================================================
    magika                        # AI-powered file type detection (works standalone, not just for AI)
    python313Packages.markitdown  # Convert files and office documents to Markdown

    # =============================================================================
    # LLM UTILITIES
    # =============================================================================
    # 0.9.2 via flake overlays/llmfit.nix until nixpkgs-unstable ships it
    pkgsUnstable.llmfit

    # =============================================================================
    # CORE DEVELOPMENT TOOLS
    # =============================================================================
    curl              # Transfer data with URLs (HTTP, FTP, etc.)
    wget              # Non-interactive network downloader
    git               # Distributed version control system
    git-lfs           # Git Large File Storage (handle large files in git)
    nodejs_22         # Node.js runtime for opencode, codex, MCP servers, and general JS tooling
    zsh               # Z shell (alternative to bash)
    zoxide            # Replaces cd (frecent); zi = interactive picker
    broot             # br + Alt+Enter when cd/zi do not know the path yet
    nh                # Clean Home Manager/Nix build output and package diffs
    tmux              # Terminal multiplexer (split terminals, sessions)
    nixRefresh
    tmuxProject

    # =============================================================================
    # DOCKER & CONTAINER TOOLS
    # =============================================================================
    docker            # Container platform CLI
    docker-compose    # Multi-container Docker application manager
    lazydocker        # TUI for Docker management (containers, images, logs)
    dive              # Explore Docker image layers and optimize size

    # =============================================================================
    # GIT TOOLS
    # =============================================================================
    lazygit           # TUI for Git operations (commits, branches, rebasing)
    gh                # GitHub CLI (PRs, issues, `gh auth login`)

    # =============================================================================
    # C/C++ DEVELOPMENT
    # =============================================================================
    # Build Tools
    bear              # Generate compile_commands.json from existing builds
    ccache            # Compiler cache for faster rebuilds
    cmake             # Cross-platform build system generator
    ninja             # Fast build system (alternative to make)
    gnumake           # GNU Make build automation tool
    pkg-config        # Discover compiler and linker flags for dependencies
    
    # GCC Toolchain (default compiler)
    gcc               # GNU Compiler Collection (C, C++, etc.)
    gdb               # GNU Debugger for GCC
    lldb              # LLVM debugger, often useful for modern C++ stacks
    
    # Clang/LLVM Tools (formatting, linting, LSP)
    clang-tools       # clang-format, clang-tidy, clangd LSP server
    # Note: Full clang compiler conflicts with gcc's 'cc' binary
    # For clang compiler, use per-project flake or remove gcc

    # =============================================================================
    # PYTHON DEVELOPMENT
    # =============================================================================
    python3           # Python interpreter (latest stable)
    python3Packages.pip  # Python package installer
    python3Packages.virtualenv  # Virtual environment tool
    uv                # Fast Python package installer (pip alternative)
    ruff              # Fast Python linting and formatting

    # =============================================================================
    # NETWORKING & SECURITY
    # =============================================================================
    openssh           # SSH client and tools
    tailscale         # VPN mesh network (zero-config)
    
    # =============================================================================
    # FONTS
    # =============================================================================
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    
    # =============================================================================
    # TEXT EDITORS & TOOLS
    # =============================================================================
    nano              # Simple terminal text editor
    
    # =============================================================================
    # COMPRESSION & FILE UTILITIES
    # =============================================================================
    unzip             # Extract ZIP archives
    zip               # Create ZIP archives
    gzip              # GNU compression utility
    which             # Locate a command in PATH
    file              # Determine file type
    less              # Pager for viewing text files
    more              # Basic pager (less is more)
    man-pages         # Linux manual pages
    man-db            # Man page indexing and search
    
    # =============================================================================
    # MULTIMEDIA & MEDIA TOOLS
    # =============================================================================
    ffmpeg            # Video/audio converter and processor
  ];
}
