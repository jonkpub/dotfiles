# Native-agent integration registry

`AGENTS.md` and the private local System Map are the canonical workstation
context. Provider-specific files are compatibility adapters only: they contain
one managed import to `~/AGENTS.md` and must never duplicate policy, machine
state, credentials, or a provider-specific workflow.

## Supported local integrations

| Tool | Context mechanism | Adapter policy | Launch eligibility |
| --- | --- | --- | --- |
| Codex | Discovers `AGENTS.md` in the working-tree / home guidance chain | None; direct | Verified when `~/AGENTS.md` exists. |
| OpenCode v2 | Discovers `AGENTS.md` from the current location through home | None; direct | Verified when `~/AGENTS.md` exists. |
| Claude Code | Reads `CLAUDE.md`; imports `AGENTS.md` with `@` syntax | Managed `~/.claude/CLAUDE.md` import only when required | Verified after the managed import exists. |
| Gemini CLI | Reads global and project `GEMINI.md`; imports files with `@` syntax | Managed `~/.gemini/GEMINI.md` import only when required | Verified after the managed import exists. |
| Hermes (default profile) | Loads global `SOUL.md`, plus project `AGENTS.md` from its working directory | Managed `~/.hermes/SOUL.md` bridge that directs every default-profile session to `~/AGENTS.md` | Verified after the bridge and runtime check pass. |

The registry is deliberately conservative. A tool that is not detected, whose
context behavior has not been verified, or whose existing user-owned file
cannot be merged safely remains visible as `needs attention`; it is never
silently enabled.

## Adapter ownership

The generator uses this marker:

```markdown
<!-- managed-by: workstation-agent-adapter-v1; adapter: <tool> -->
@~/AGENTS.md
```

It may create a missing adapter. It replaces only an adapter carrying that
exact marker. When a user-owned adapter file already exists, normal apply mode
leaves it unchanged. An explicit merge mode creates a private timestamped
backup under `~/.local/state/workstation/agent-adapters/backups/` before it
appends the managed import or Hermes SOUL bridge. Hermes named profiles remain
unchanged; this bridge applies only to the default Hermes profile.

## Responsibilities

- `bin/agent-context`: detects supported local CLIs, reports context readiness,
  and creates or merges only the minimal required adapters.
- `bin/refresh-system-map`: includes this registry in the private System Map.
- Agent Console: shows context readiness separately from a local `--version`
  runtime check, and only offers local launches when both are healthy.

This layer does not manage provider authentication, models, usage, routing,
MCP configuration, memories, or credentials. Those remain outside the public
dotfiles core.

## Optional private Agentd integration

When `~/Projects/labs/agentd` exists, read its `STATUS.md` for verified local
capabilities and its `AGENTS.md` before changing the service. This private
checkout is separate from public dotfiles; never copy its runtime state into
this repository or the System Map.

- Desktop controls: Agentd's island, window, and sidebar share the local
  dashboard at `http://127.0.0.1:4176`. Linux can use the same local dashboard.
- File organization: read `~/Projects/labs/agentd/docs/organization.md` before
  proposing a move. Inventory is metadata-only; selected-file moves require a
  preview, human confirmation, and an undo path. Repositories remain held.
- Exchange: the dashboard catalogs declared packages and offers explicit
  import/export. This is not permission to index personal iCloud or sync roots.
- Provider continuation: read `~/Projects/labs/agentd/docs/handoff.md`. Reviewable
  packets start a new session; they do not resume an existing native session.
- Approvals and leases are local permission records, not OS enforcement.
  Agents must not approve their own requests or treat emergency-mode records
  as authority to retrieve personal credentials.

Check service availability only when the task needs it. A missing or offline
daemon must not prevent ordinary coding, reading the local map, or recovery.
Never infer that an installed adapter guarantees the native agent has read
context or participates in daemon authorization.
