# Portable dotfiles

A small, public, provider-neutral configuration core for one macOS workstation
and one Omarchy Linux workstation. It establishes the shared floor that native
agents and ordinary shells can rely on without trying to turn every AI product,
cloud service, desktop preference, or private credential into dotfiles.

The desired permanent home is a standalone public repository:

```text
GitHub: jonkpub/dotfiles
└── public portable core
    ├── provider-neutral AGENTS.md
    ├── generated private system map
    ├── macOS, Linux, and Omarchy profiles
    ├── shell, Git, tmux, and terminal-tool configuration
    ├── organization policy and safe bootstrap
    └── Linux verification
```

`~/dotfiles` will be a direct checkout of that repository. There is no rsync
mirror, profile-repository subtree, router installation, credential store, or
background service in this core.

## What this manages

- a concise global [`AGENTS.md`](AGENTS.md) that tells compatible native agents
  to read a locally generated system map first;
- safe links for the selected shell profile, Git, tmux, Starship, Atuin, and
  broot configuration;
- an advisory organization policy for projects, personal files, inboxes, and
  the deliberate iCloud `Agent Exchange` boundary;
- package *references* for macOS, generic Linux, and Omarchy;
- a default-deny bootstrap and regression tests.

It intentionally does **not** manage:

- model-provider configuration, API keys, raw credentials, private keys,
  personal accounts, or a secrets broker;
- Tailnet ACLs, exit nodes, cloud servers, SSH setup, or remote login;
- an Omarchy desktop, Hyprland configuration, theme, monitor layout, or
  keybindings;
- automatic file reorganization, desktop daemons, provider routing, or any
  always-on agent service.

Those are future, separately scoped projects. A later private capability
broker can use the same context and policy vocabulary without being embedded
in this public repository.

## Profiles

| Profile | Shell behavior | Package reference | Platform boundary |
| --- | --- | --- | --- |
| `darwin` | Shared Zsh entrypoints | [`profiles/darwin/Brewfile`](profiles/darwin/Brewfile) | Personal applications and machine paths stay local. |
| `linux` | Shared Zsh entrypoints | [`profiles/linux/packages.txt`](profiles/linux/packages.txt) | Generic Linux only; distribution installation stays explicit. |
| `omarchy` | Managed Bash workflow fragment; existing Omarchy Bash entrypoint remains user-owned | [`profiles/omarchy/packages.txt`](profiles/omarchy/packages.txt) | Omarchy-owned `/usr/share/omarchy` and desktop configuration remain untouched, including stock Starship. |

The installer detects the current platform and refuses a forced profile that
does not match it. Omarchy remains Bash-first by default; this repo never
changes the login shell or writes `~/.bashrc`. On Omarchy it installs the
shared fragment at `~/.local/share/dotfiles/bash/workflow.bash` and leaves the
existing Omarchy Bash entrypoint byte-for-byte untouched. An agent may propose
one reversible include in that user-owned file only after presenting the
specific diff; the core installer never performs that migration.

## Bootstrap model

The usual person does not need to memorize a command. An approved native agent
can inspect the plan and run the same safe bootstrap. The command remains for
recovery, automation, CI, and agents:

```sh
git clone <approved-public-origin> ~/dotfiles
~/dotfiles/bin/install-core
```

The first command is a complete dry-run. It reports every link, every
directory it would create, the detected profile, and the corresponding package
reference. It does not install packages or write files.

After reviewing the exact plan, apply it explicitly:

```sh
~/dotfiles/bin/install-core --apply
```

`install-core` refuses to replace ordinary files, directories, or foreign
symlinks. It also creates the private local system map atomically at:

```text
~/.local/share/workstation/SYSTEM_MAP.md
```

That map is deliberately not tracked. It gives agents session-fresh, concise
context: machine profile, project placement policy, safe helper inventory,
publication state, and core rules. It contains no credential values, host
inventory, raw Tailnet state, or personal account data.

The public policy sources live in `config/workstation/`: principles, Git
workflow, project lifecycle, machine roles, organization policy, and safety.
The generated map names these files so an agent can load only the relevant
document for its current task.

If a managed map needs a refresh:

```sh
~/dotfiles/bin/refresh-system-map --apply
```

## Agent-owned project roots

Agents can create new work through the dry-run-first helper without moving or
classifying existing user content:

```sh
~/dotfiles/bin/new-agent-project --kind scratch --name browser-experiment
~/dotfiles/bin/new-agent-project --kind project --area labs --name agent-console --apply
```

Scratch work is placed under `~/Projects/_scratch/YYYY-MM-topic`. Durable
projects are placed under `~/Projects/<area>/<project>` and initialized as new
Git repositories. Existing targets are always refused.

## Local extensions

Keep deliberate machine-specific preferences outside the public core:

- Zsh: `~/.config/dotfiles/local/zsh.zsh`
- Omarchy Bash: `~/.config/dotfiles/local/bash.sh`
- Git identity, signing, and credential-related settings:
  `~/.config/dotfiles/local/gitconfig`
- macOS package/application choices: a local, untracked Brewfile
- Omarchy desktop configuration: its documented user-owned files under
  `~/.config`, managed with Omarchy’s own setup tools

The shell entrypoints load these files only when present. They are optional;
they are not created, published, or assumed by this repository.

On a fresh machine, the bootstrap creates a writable local `~/.gitconfig`
wrapper that includes the public portable fragment and the optional local Git
file above. Normal `git config --global` writes therefore stay local and can
never write through a symlink into this public repository. If `~/.gitconfig`
already exists, the installer preserves it and still installs the portable
fragment; an agent must show a reversible include-only migration before
enabling that fragment for the existing global configuration.

## Organization policy

The policy in [`config/workstation/organization.md`](config/workstation/organization.md)
is deliberately flexible:

- canonical development work lives under `~/Projects/<area>/<project>`;
- disposable agent experiments start under `~/Projects/_scratch/YYYY-MM-topic`;
- durable personal material lives under `~/Documents/<area>` or the platform
  media library;
- Desktop and Downloads are inboxes, not long-term authority;
- iCloud is personal/archive storage; `Agent Exchange` is the intentional
  cross-boundary hand-off point;
- agents may classify and propose moves, but durable moves require a preview,
  reference and Git check, recovery path, and approval.

This is a clean forward model, not a bulk migration command. Existing Mac
content is classified before it is moved, and the policy can evolve without
breaking repositories because project roots, Git remotes, and references are
checked first.

## Verification and publication

Run the portable bootstrap regression suite locally:

```sh
zsh ~/dotfiles/tests/install-core-test.zsh
```

The repository includes a Linux CI workflow for the same test. It becomes
active only after the standalone GitHub repository exists.

Before the first public push, perform and record:

1. tracked-file secret scan;
2. machine-specific identifier and path audit;
3. clean intended Git status review;
4. proposed public-file manifest review;
5. bootstrap test and CI review;
6. only then GitHub repository creation, direct `origin`, and first push.

The old mirror-based dotfiles workflow is intentionally absent from this
portable core. It remains intact in the existing local worktree until the
public projection has passed that pre-publication review and the user approves
the switch.
