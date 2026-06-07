# Zsh program configuration
# This file configures zsh with oh-my-zsh and plugins

{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    history = {
      size = 100000;
      save = 100000;
      path = "${config.home.homeDirectory}/.zsh_history";
      append = true;
      extended = true;
      share = false;
      ignoreDups = true;
      ignoreAllDups = false;
      saveNoDups = false;
      findNoDups = false;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
    };
    setOptions = lib.mkAfter [
      "INC_APPEND_HISTORY"
      "HIST_REDUCE_BLANKS"
      "HIST_VERIFY"
    ];
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
      theme = "";  # Starship prompt (programs/starship.nix)
    };
    
    # Shell init: ordered fragments (replaces deprecated initExtra; see HM zsh module)
    initContent = lib.mkMerge [
      (lib.mkOrder 850 ''
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
        # Gruvbox colors for zsh-syntax-highlighting
        # Declare associative array before assignments: initContent runs before the plugin is sourced.
        typeset -gA ZSH_HIGHLIGHT_STYLES
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

        # GUI-style line editor keys (Ctrl+arrow, Ctrl+C copy, Ctrl+Enter, etc.)
        ${builtins.readFile ../configs/zsh-keybindings.sh}

        # Directory navigation (proper tools, not custom wrappers):
        #   z / zi  — zoxide (frecent jumps; zi = official interactive fzf UI)
        #   br      — broot (tree finder for any path, Alt+Enter to cd)
        #   Alt+C   — fzf directory jump (programs.fzf zsh integration)
        export _ZO_FZF_OPTS="--height 40% --layout=reverse --border rounded --preview 'eza -1 --color=always {} 2>/dev/null || ls -la {}'"
        eval "$(zoxide init zsh)"
        if command -v broot >/dev/null 2>&1; then
          eval "$(broot --print-shell-function zsh 2>/dev/null)" || true
        fi
      '')
      (lib.mkOrder 1200 ''
        # Force Ctrl+R widget options explicitly. In some HM/fzf setups the
        # dedicated historyWidgetOptions don't reliably surface in live zsh.
        export FZF_CTRL_R_OPTS="--height=80% --layout=reverse --border=rounded --bind 'ctrl-r:toggle-sort' --header 'Ctrl-R: toggle sort'"

        # Replace fzf's default history widget:
        # - keep history storage intact, but show only the newest copy of each
        #   exact command in the Ctrl+R picker so repeated commands do not spam
        # - display only command text so line numbers never clutter the list
        # - flatten embedded newlines so pasted multi-line commands stay readable
        # NOTE: zsh does not treat $'\t' inside double quotes as a tab (unlike bash).
        # Use a real tab from Nix (${"\t"}) in the --delimiter argument so fzf splits fields.
        if (( $+functions[__fzfcmd] && $+functions[__fzf_defaults] )); then
          fzf-history-widget() {
            local selected num entry
            local -a entries
            local -A seen
            setopt localoptions pipefail no_aliases noglobsubst noposixbuiltins

            for num in ''${(Onk)history}; do
              entry=$history[$num]
              if [[ -n ''${seen[$entry]-} ]]; then
                continue
              fi
              seen[$entry]=1
              entry=''${entry//$'\n'/' <NL> '}
              entry=''${entry//$'\t'/'    '}
              entries+=("$num"$'\t'"$entry")
            done

            selected="$(
              print -r -l -- ''${entries[@]} |
                FZF_DEFAULT_OPTS=$(__fzf_defaults "" "--delimiter=${"\t"} --with-nth=2.. --scheme=history --highlight-line ''${FZF_CTRL_R_OPTS-} --query=''${(qqq)LBUFFER} +m") \
                FZF_DEFAULT_OPTS_FILE= $(__fzfcmd)
            )"
            local ret=$?

            if [[ -n "$selected" && "$selected" =~ ^[0-9]+ ]]; then
              zle vi-fetch-history -n $MATCH
            fi

            zle reset-prompt
            return $ret
          }
          zle -N fzf-history-widget
        fi

        # Force Ctrl+R to use fzf's history widget, in case any plugin
        # (oh-my-zsh, syntax-highlighting, etc.) rebound it after fzf loaded.
        if (( $+functions[fzf-history-widget] )); then
          bindkey '^R' fzf-history-widget
        fi
      '')
    ];
    
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
