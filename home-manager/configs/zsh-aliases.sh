# Zsh aliases and environment variables
# This file contains all your shell aliases and environment setup

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================
export TERM=xterm-256color
export EDITOR='nvim'
export BROWSER='firefox'
export PATH="$HOME/.local/bin:$PATH"

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