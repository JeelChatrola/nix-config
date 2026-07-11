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
    
    # Zsh plugins (order matters): fzf-tab must load before plugins that wrap ZLE widgets.
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
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

        # Refresh inherited session state so existing terminals pick up FZF theme changes.
        export FZF_DEFAULT_OPTS=${lib.escapeShellArg (lib.concatStringsSep " " config.programs.fzf.defaultOptions)}

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
        # Tokyo Night colors for zsh-syntax-highlighting
        # Declare associative array before assignments: initContent runs before the plugin is sourced.
        typeset -gA ZSH_HIGHLIGHT_STYLES
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
        ZSH_HIGHLIGHT_STYLES[default]='fg=#c0caf5'
        ZSH_HIGHLIGHT_STYLES[command]='fg=#9ece6a'
        ZSH_HIGHLIGHT_STYLES[alias]='fg=#9ece6a'
        ZSH_HIGHLIGHT_STYLES[builtin]='fg=#e0af68'
        ZSH_HIGHLIGHT_STYLES[function]='fg=#7dcfff'
        ZSH_HIGHLIGHT_STYLES[path]='fg=#7aa2f7,underline'
        ZSH_HIGHLIGHT_STYLES[globbing]='fg=#bb9af7'
        ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#bb9af7'
        ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#ff9e64'
        ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#ff9e64'
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#bb9af7'

        # Import aliases and environment from external file
        ${builtins.readFile ../configs/zsh-aliases.sh}

        # GUI-style line editor keys (Ctrl+arrow, Ctrl+C copy, Ctrl+Enter, etc.)
        ${builtins.readFile ../configs/zsh-keybindings.sh}

        # Directory navigation:
        #   cd / zi — zoxide (--cmd cd): frecent jumps on paths you have used
        #   br      — broot: tree search for paths you have never visited; Alt+Enter to cd
        export _ZO_FZF_OPTS="--height 40% --layout=reverse --border rounded --preview 'eza -1 --color=always {} 2>/dev/null || ls -la {}'"
        eval "$(zoxide init zsh --cmd cd)"
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

        # Home Manager's fzf integration loads after normal plugins and also
        # claims Tab. Give Tab back to the richer, grouped fzf-tab completer.
        if (( ''${+widgets[fzf-tab-complete]} )); then
          bindkey -M emacs '^I' fzf-tab-complete
        fi
      '')
    ];
    
    # Completion configuration - runs after compinit and plugins
    completionInit = ''
      # fzf-tab configuration
      zstyle ':completion:*:git-checkout:*' sort false
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:*' fzf-flags --height=80% --layout=reverse --border=sharp
      zstyle ':fzf-tab:*' switch-group '<' '>'
      zstyle ':fzf-tab:*' continuous-trigger '/'
      zstyle ':fzf-tab:complete:*:*' fzf-preview \
        'if [[ -d $realpath ]]; then eza -1 --color=always --icons $realpath; elif [[ -f $realpath ]]; then bat --color=always --style=numbers --line-range=:200 $realpath; fi'
    '';
  };
}
