# Packages configuration
# This file contains all the packages you want to install

{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [    
    # =============================================================================
    # SYSTEM UTILITIES
    # =============================================================================
    tree              # Display directory structure as a tree
    htop              # Interactive process viewer (better than top)
    btop              # Modern resource monitor (better than htop)
    ctop              # Container metrics and monitoring (like top for containers)
    ripgrep           # Fast grep alternative (search file contents)
    fd                # Fast find alternative (search file names)
    bat               # Cat with syntax highlighting and git integration
    eza               # Modern ls replacement with colors and icons
    fzf               # Fuzzy finder for command-line
    jq                # JSON processor and query tool
    yq-go             # YAML processor (like jq but for YAML)
    neofetch          # System information display tool
    rsync             # Remote file synchronization
    lf                # Terminal file manager (fast, simple, vi-like)
    gping             # Ping with a graph (visual network latency)
    
    # =============================================================================
    # PRODUCTIVITY & KNOWLEDGE TOOLS
    # =============================================================================
    navi              # Interactive cheat sheet tool (command examples)
    tldr              # Simplified man pages (community-driven examples)
    buku              # Powerful bookmark manager for URLs

    # =============================================================================
    # CORE DEVELOPMENT TOOLS
    # =============================================================================
    curl              # Transfer data with URLs (HTTP, FTP, etc.)
    wget              # Non-interactive network downloader
    git               # Distributed version control system
    zsh               # Z shell (alternative to bash)
    tmux              # Terminal multiplexer (split terminals, sessions)

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

    # =============================================================================
    # C/C++ DEVELOPMENT
    # =============================================================================
    # Build Tools
    cmake             # Cross-platform build system generator
    ninja             # Fast build system (alternative to make)
    gnumake           # GNU Make build automation tool
    
    # GCC Toolchain (default compiler)
    gcc               # GNU Compiler Collection (C, C++, etc.)
    gdb               # GNU Debugger for GCC
    
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
