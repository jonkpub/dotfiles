# Machine Roles

## macOS workstation

- Primary personal workstation and public dotfiles authoring checkout.
- Uses the portable Zsh profile and local macOS-only overrides where needed.
- iCloud remains a personal/archive layer; `Agent Exchange` is a deliberate
  hand-off boundary, not a general cross-platform repository location.

## Omarchy workstation

- Linux desktop reference and Tailnet-reachable development machine.
- Remains Bash-first and keeps Omarchy-owned desktop configuration stock.
- Uses the same public agent context, Git, tmux, and project policy as macOS.
- Keeps Omarchy stock Starship configuration rather than the portable prompt.

## Future private services

- Oracle A remains the separately managed Tailnet exit-node role.
- Any secrets broker, catalog, indexing, provider handoff, or file-sync service
  is a private follow-on project. This public map records capabilities and
  references, never credential values.
