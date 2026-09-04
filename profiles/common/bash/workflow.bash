# Shared interactive Bash enhancements. This is a fragment, not a shell
# entrypoint: each platform keeps ownership of the entrypoint it requires.

case $- in
  *i*) ;;
  *) return ;;
esac

if [ -t 1 ] && [ "${TERM:-dumb}" != dumb ]; then
  command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
  command -v atuin >/dev/null 2>&1 && eval "$(atuin init bash)"
  command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"
fi
