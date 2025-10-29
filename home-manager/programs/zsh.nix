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
    # 1. fzf-tab (after compinit, before autosuggestions)
    # 2. zsh-autosuggestions
    # 3. zsh-syntax-highlighting
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "v1.1.2";
          sha256 = "sha256-Qv8zAiMtrr67CbLRrFjGaPzFZcOiMVEFLg1Z+N6VMhg=";
        };
      }
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
        "z"
        "extract"
        "colored-man-pages"
        "command-not-found"
        # NOTE: "fzf" plugin removed - conflicts with fzf-tab
        "ssh-agent"
      ];
      theme = "robbyrussell";
    };
    
    # Shell initialization - runs before compinit
    initExtra = ''
      # Enable useful shell options
      setopt AUTO_CD
      setopt CORRECT
      setopt CORRECT_ALL
      setopt HIST_EXPIRE_DUPS_FIRST
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_VERIFY
      setopt SHARE_HISTORY
      # Initialize ZSH_HIGHLIGHT_HIGHLIGHTERS array
      ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor root line)
      
      # Import aliases and environment from external file
      ${builtins.readFile ../configs/zsh-aliases.sh}
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
