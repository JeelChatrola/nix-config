# Zsh program configuration
# This file configures zsh with oh-my-zsh and plugins

{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # NOTE: autosuggestions and syntax-highlighting must load AFTER fzf-tab
    # So we disable the built-in options and load them manually via plugins
    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;
    
    # Set zsh as default shell
    defaultKeymap = "emacs";
    
    # Zsh plugins (order matters!)
    # 1. zsh-autosuggestions
    # 2. zsh-syntax-highlighting
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];
    
    # Oh-my-zsh configuration
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "docker-compose"
        "kubectl"
        "terraform"
        "aws"
        "python"
        "node"
        "npm"
        "tmux"
        "sudo"
        "extract"
        "colored-man-pages"
        "command-not-found"
        "ssh-agent"
      ];
      theme = "robbyrussell";  # Simple, clean prompt
    };
    
    # Shell initialization - runs before compinit
    initContent = ''
      # Enable useful shell options
      setopt AUTO_CD
      
      # Auto-load SSH keys
      if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)" > /dev/null
      fi
      
      # Add GitHub SSH key if it exists and isn't already loaded
      if [ -f ~/.ssh/github_auth ] && ! ssh-add -l 2>/dev/null | grep -q github_auth; then
        ssh-add ~/.ssh/github_auth 2>/dev/null
      fi
      setopt CORRECT
      setopt CORRECT_ALL
      setopt HIST_EXPIRE_DUPS_FIRST
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_VERIFY
      setopt SHARE_HISTORY
      
      # Gruvbox colors for zsh-syntax-highlighting
      ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
      ZSH_HIGHLIGHT_STYLES[default]='fg=#ebdbb2'
      ZSH_HIGHLIGHT_STYLES[command]='fg=#b8bb26'
      ZSH_HIGHLIGHT_STYLES[alias]='fg=#b8bb26'
      ZSH_HIGHLIGHT_STYLES[builtin]='fg=#fabd2f'
      ZSH_HIGHLIGHT_STYLES[function]='fg=#8ec07c'
      ZSH_HIGHLIGHT_STYLES[path]='fg=#83a598,underline'
      ZSH_HIGHLIGHT_STYLES[globbing]='fg=#d3869b'
      ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#d3869b'
      ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#fe8019'
      ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#fe8019'
      ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#d3869b'
      
      # Import aliases and environment from external file
      ${builtins.readFile ../configs/zsh-aliases.sh}
      
      # Initialize zoxide (fast directory jumper)
      # --cmd cd: Replace 'cd' command so zoxide learns directories automatically
      eval "$(zoxide init zsh --cmd cd)"
    '';
    
    # Completion configuration - runs after compinit and plugins
    completionInit = ''
      # fzf-tab configuration
      # Disable sort when completing git checkout
      zstyle ':completion:*:git-checkout:*' sort false
      
      # Set descriptions format to enable group support
      zstyle ':completion:*:descriptions' format '[%d]'
      
      # Set list-colors to enable filename colorizing
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      
      # Force zsh not to show completion menu (let fzf-tab handle it)
      zstyle ':completion:*' menu no
      
      # Preview directory contents with eza when completing cd
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
      
      # Switch group using '<' and '>'
      zstyle ':fzf-tab:*' switch-group '<' '>'
    '';
  };
}
