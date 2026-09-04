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
| Hermes | Can load `AGENTS.md` from the active working directory | No global adapter until its global-loading behavior is explicitly verified | Not offered by the launcher yet. |

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
appends the managed import.

## Responsibilities

- `bin/agent-context`: detects supported local CLIs, reports context readiness,
  and creates or merges only the minimal required adapters.
- `bin/refresh-system-map`: includes this registry in the private System Map.
- Agent Console: shows the compatibility matrix and only offers local launches
  for tools whose context path is currently verified.

This layer does not manage provider authentication, models, usage, routing,
MCP configuration, memories, or credentials. Those remain outside the public
dotfiles core.
