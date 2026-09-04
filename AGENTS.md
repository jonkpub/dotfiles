# Workstation Agent Context

This is the provider-neutral entry point for agents working anywhere beneath
this home directory. It is intentionally short: do not treat it as a complete
prompt or duplicate product-specific configuration.

## Read first

Before planning, editing, moving files, running setup, or publishing changes,
read the local system map if it exists:

`~/.local/share/workstation/SYSTEM_MAP.md`

The map is generated locally, is machine-specific, and is not part of the
public dotfiles projection. If it is missing or older than the current task
needs, refresh it with `~/dotfiles/bin/refresh-system-map` before relying on
machine state.

Then read the nearest repository `AGENTS.md` or equivalent project guidance.
Project instructions refine this context; they do not replace its safety rules.

## Core rules

- `~/dotfiles` is the source of truth for tracked shell, Git, terminal, and
  workstation configuration. Edit it rather than its home-directory stubs.
- Check Git status before changing an existing project. Preserve unrelated,
  uncommitted user work.
- Treat generated inventory and local maps as outputs. Change their sources,
  then regenerate them.
- Never put credential values, private keys, tokens, personal-account data, or
  private host inventory into tracked configuration, generated agent context,
  prompts, logs, or public projections.
- New agent-owned work may use the organization guidance in the system map.
  Existing durable files and projects are moved only with an explicit preview,
  reference/Git check, recovery path, and user approval.
- Do not run a publish, install, Tailnet, cloud, or destructive action merely
  because it is available. Explain the concrete change and verify the target.

## Dotfiles publication

This repository is designed to be a direct, standalone public repository when
an `origin` remote is configured. It has no mirror or subtree workflow. Before
any first publication, review the proposed public manifest, run the tracked
file secret and machine-identifier checks, and confirm that the working tree
contains only intended changes. Do not publish unexplained, generated, private,
or secret-bearing content.

## Scope boundary

Native agents remain the primary interface. This shared context is the
provider-neutral source; provider-specific files are not a second policy
system. A future private broker, Tailnet services, cross-machine catalog, and
provider handoff remain separate projects unless the user explicitly asks to
work on them.
