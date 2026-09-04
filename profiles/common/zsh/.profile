# Portable POSIX login-shell environment.

path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

[ -d "$HOME/.local/bin" ] && path_prepend "$HOME/.local/bin"
[ -d "$HOME/.cargo/bin" ] && path_prepend "$HOME/.cargo/bin"
export PATH
