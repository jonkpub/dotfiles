# Portable interactive Zsh setup. Platform and provider integrations stay in
# explicit local overrides, not in this public common profile.

[[ -o interactive ]] || return

autoload -Uz compinit
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
if [[ -d "$CACHE_DIR" || ( ! -e "$CACHE_DIR" && mkdir -p -- "$CACHE_DIR" 2>/dev/null ) ]]; then
  compinit -d "$CACHE_DIR/zcompdump"
else
  compinit -C
fi

if [[ -t 1 && "${TERM:-dumb}" != dumb ]]; then
  command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
  command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh)"
  command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
fi

LOCAL_OVERRIDE="$HOME/.config/dotfiles/local/zsh.zsh"
[[ -r "$LOCAL_OVERRIDE" ]] && source "$LOCAL_OVERRIDE"
