# Optional GUI-style line editor keys. Standard emacs keys (Ctrl+A/E, Ctrl+C interrupt)
# are left at zsh defaults so behavior matches a normal terminal.

# Word movement (GNOME Terminal / VS Code style)
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# New line without executing (Ctrl+Enter)
insert-newline() {
  LBUFFER="$LBUFFER"$'\n'"$RBUFFER"
}
zle -N insert-newline
bindkey '^[[13;5~' insert-newline
bindkey '^[^M' insert-newline
