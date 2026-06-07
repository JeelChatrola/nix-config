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
#   nix-refresh --ai         base + AI stack (opencode, hermes, Docker, Hermes gateway restart)
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
# AI STACK
# =============================================================================
# Set by home-manager (~/nix-config/ai-stack by default; change aiConfigRoot in flake.nix if cloned elsewhere).
: "${AI_STACK_DIR:=$HOME/nix-config/ai-stack}"

# docker compose for ai-stack; reads ai-stack/.env when present (copy from .env.example).
_ai_compose() {
  bash "$AI_STACK_DIR/scripts/docker-compose.sh" "$@"
}

ai-up() {
  bash "$AI_STACK_DIR/bin/ai-stack" up
}

ai-down() { _ai_compose down; }
ai-restart() { _ai_compose restart; }
ai-logs() { _ai_compose logs -f; }
ai-ps() { _ai_compose ps; }
ai-pull() { _ai_compose pull; }

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

# install-skill.py: skills, templates, agents (see ai-stack/README.md). bootstrap needs explicit flags.
alias ai-proj='python3 "$AI_STACK_DIR/scripts/install-skill.py"'
# Opinionated: full bootstrap = templates + opencode agent .md + all skills -> cursor, opencode roots.
ai-boot() {
  python3 "$AI_STACK_DIR/scripts/install-skill.py" bootstrap -y --all --to cursor --to opencode "$@"
}

# =============================================================================
# SMART CD (zoxide + fzf + fd)
# =============================================================================
# z / zi  — zoxide: jump to dirs you have visited before
# cd      — alone: pick any dir under $HOME via fzf
# cd foo  — normal cd; if path missing, fuzzy-find dirs matching foo (incl. never visited)
# cdf     — always open the fzf dir picker (alias)

_pick_dir() {
  local query="${1:-}"
  local -a fzf_args=(
    --prompt='cd> '
    --height 40%
    --layout=reverse
    --border rounded
    --preview 'eza -1 --color=always {} 2>/dev/null || ls -la {}'
    --exit-0
  )
  [[ -n "$query" ]] && fzf_args+=(--query "$query" --select-1)

  {
    fd --type d --max-depth 5 . 2>/dev/null
    fd --type d --hidden --follow --max-depth 7 \
      --exclude .git --exclude node_modules --exclude .cache --exclude .local/share/Trash \
      "$HOME" 2>/dev/null
  } | awk '!seen[$0]++' | fzf "${fzf_args[@]}"
}

cd() {
  local dest
  if (( $# == 0 )); then
    dest="$(_pick_dir)" || return $?
    builtin cd -- "$dest"
  elif (( $# == 1 )) && [[ ! -d "$1" ]]; then
    dest="$(_pick_dir "$1")" || return $?
    builtin cd -- "$dest"
  else
    builtin cd -- "$@" || return $?
  fi
  command zoxide add -- "$(pwd -P)" 2>/dev/null
}

cdf() {
  local dest
  dest="$(_pick_dir "$@")" || return $?
  cd -- "$dest"
}

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