# Safety and Autonomy

## Default authority

- Read, inspect, classify, and propose freely within the requested scope.
- Create agent-owned scratch material when it is clearly needed for the task.
- Require explicit task scope for destructive actions, publication, remote
  service changes, account changes, durable user-file moves, and elevation.

## Reversible change standard

- Preview the exact target and impact before changing durable configuration.
- Prefer backups, moves, branches, worktrees, and atomic replacement to
  irreversible deletion or broad overwrite.
- Verify after the change and state where recovery material lives.

## Credentials and external systems

- Never place raw credentials, tokens, private keys, account data, or personal
  identity material in public configuration, generated maps, prompts, or logs.
- Use authenticated applications and scoped capabilities when available.
- Treat Tailnet, cloud, secrets, provider routing, and external messages as
  explicit boundaries even when an agent has technical access.
