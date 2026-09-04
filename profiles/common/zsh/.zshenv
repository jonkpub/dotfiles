# Portable non-interactive shell environment.
# Keep this fast: no package-manager, editor, agent, or platform initialization.

typeset -U path PATH
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
[[ -d "$HOME/.cargo/bin" ]] && path=("$HOME/.cargo/bin" $path)
export PATH
