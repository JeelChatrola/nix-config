# GUI-style ZLE keybindings for Alacritty (xterm-style CSI sequences).
# Requires xclip on PATH (home.packages).

_clipboard-copy() {
  print -rn -- "$1" | xclip -in -selection clipboard 2>/dev/null
}

# Word movement
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Word selection (Ctrl+Shift+Arrow)
bindkey '^[[1;6C' select-forward-word
bindkey '^[[1;6D' select-backward-word

# Character selection (Shift+Arrow)
bindkey '^[[1;2C' select-forward-char
bindkey '^[[1;2D' select-backward-char

# Select entire command line (Ctrl+A)
select-all-line() {
  CURSOR=$#BUFFER
  MARK=0
  REGION_ACTIVE=1
}
zle -N select-all-line
bindkey '^A' select-all-line

# New line without executing (Ctrl+Enter)
insert-newline() {
  LBUFFER="$LBUFFER"$'\n'"$RBUFFER"
}
zle -N insert-newline
bindkey '^[[13;5~' insert-newline
bindkey '^[^M' insert-newline

# Ctrl+C: copy active selection, otherwise interrupt
copy-or-interrupt() {
  if (( REGION_ACTIVE )); then
    _clipboard-copy "$BUFFER[$MARK,$CURSOR]"
    REGION_ACTIVE=0
    MARK=$CURSOR
  else
    zle send-break
  fi
}
zle -N copy-or-interrupt
bindkey '^C' copy-or-interrupt

# Ctrl+X: cut selection to clipboard
cut-region() {
  if (( REGION_ACTIVE )); then
    _clipboard-copy "$BUFFER[$MARK,$CURSOR]"
    zle kill-region
  fi
}
zle -N cut-region
bindkey '^X' cut-region
