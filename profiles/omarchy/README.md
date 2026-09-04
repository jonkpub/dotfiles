# Omarchy profile

Omarchy is the Linux desktop reference, not a subtree to overwrite. Keep
Omarchy-owned files in `/usr/share/omarchy` untouched. Put personal desktop
overrides in the documented user-owned locations beneath `~/.config`, such as
`~/.config/hypr`, `~/.config/omarchy`, and `~/.config/omarchy/themes`.

The common profile supplies the same shell, Git, tmux, agent context, and
project workflow as macOS. It supports both Bash and Zsh without changing the
login shell: Omarchy may continue using Bash, while Zsh remains an explicit
user choice. The core installs a managed Bash workflow fragment at
`~/.local/share/dotfiles/bash/workflow.bash`; it never overwrites the
user-owned `~/.bashrc`. An approved agent may propose a single reversible
include in that file after showing the diff. This profile deliberately does
not install or link Hyprland,
shell-bar, monitor, input, keybinding, or theme files until a live Omarchy
audit identifies the user's actual overrides and the relevant Omarchy version.
Use Omarchy's Setup/menu or `omarchy` CLI for changes that need a service
reload, and preserve the platform's update/reset path.

The bootstrap implementation requires the `zsh` executable, listed in
`packages.txt`; installing it does not change Omarchy's Bash login shell or
user shell configuration. Package installation remains a deliberate, separate
step from the core linker.

Omarchy retains its stock Starship configuration from
`/usr/share/omarchy/config/starship.toml`. The portable core intentionally does
not link `~/.config/starship.toml` on this profile, so Omarchy visual updates
remain platform-managed.

Machine-local desktop changes belong outside the public projection. Track only
portable, intentional overrides after reviewing them on the Omarchy machine.
