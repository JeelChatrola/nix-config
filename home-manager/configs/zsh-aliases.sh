# Zsh aliases and environment variables
# This file contains all your shell aliases and environment setup

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================
export TERM=xterm-256color
export EDITOR='nvim'
export PATH="$HOME/.local/bin:$PATH"

# Quick rebuild — works from any directory.
#   nix-refresh              base home-manager only
#   nix-refresh --ai         base + AI stack (opencode, codex, hermes, Docker, Hermes gateway restart)
#   nix-refresh --ai --no-docker   AI without Docker (gateway still restarted if installed)
nix-refresh() {
  bash "$HOME/nix-config/deploy.sh" "$@"
}

# =============================================================================
# GENERAL ALIASES
# =============================================================================
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# =============================================================================
# DEVELOPMENT ALIASES
# =============================================================================
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# =============================================================================
# TMUX ALIASES
# =============================================================================
alias t='tmux'
alias ta='tmux attach'
alias tn='tmux new-session'
alias tl='tmux list-sessions'

# =============================================================================
# SYSTEM ALIASES
# =============================================================================
alias h='history'
alias c='clear'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps aux'
alias top='htop'

# =============================================================================
# APPLICATION ALIASES
# =============================================================================
alias v='nvim'
alias nv='nvim'
alias f='fzf'
alias ssh='ssh -o ServerAliveInterval=60'

# =============================================================================
# AI STACK (private repo at ~/ai-stack)
# =============================================================================
: "${AI_STACK_DIR:=$HOME/ai-stack}"

_ai_stack() {
  bash "$AI_STACK_DIR/bin/ai-stack" "$@"
}

ai-up() { _ai_stack up; }
ai-down() { _ai_stack down; }
ai-restart() { _ai_stack down; _ai_stack up; }
ai-logs() { _ai_stack logs; }
ai-ps() { _ai_stack ps; }
ai-pull() { bash "$AI_STACK_DIR/scripts/docker-compose.sh" pull; }

# Run the Ollama CLI inside the stack container from the host.
# -it only in a real terminal; piping (e.g. ollama-list | grep) must not use -t.
ai-ollama() {
  if [[ -t 0 && -t 1 ]]; then
    docker exec -it ollama ollama "$@"
  else
    docker exec ollama ollama "$@"
  fi
}

ollama-pull() {
  ai-ollama pull "$@"
}

ollama-run() {
  ai-ollama run "$@"
}

ollama-show() {
  ai-ollama show "$@"
}

ollama-rm() {
  ai-ollama rm "$@"
}

alias ollama-list='ai-ollama list'

# Per-project skills via npx skills (see ai-stack/bin/skills)
alias ai-skills='$AI_STACK_DIR/bin/skills'
ai-boot() { "$AI_STACK_DIR/bin/skills" --skill '*' -a cursor -a opencode -y "$@"; }

# =============================================================================
# CUSTOM FUNCTIONS
# =============================================================================
# Quick directory navigation
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}