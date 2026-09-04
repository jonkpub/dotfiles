# Working Principles

## One shared operating model

- Native agents are the primary interface. This repository provides shared
  context and workflow, not a replacement for a provider's own runtime.
- Public policy is versioned here; private machine state is generated locally.
- Read the generated system map first, then the nearest project guidance.
- Prefer a small relevant context chain over a large universal prompt.

## Ownership and scope

- Treat existing user files, repositories, and uncommitted changes as owned
  until a task explicitly places them in scope.
- Agent-created work follows the organization policy; agent-owned does not
  mean automatically disposable.
- Keep platform-specific preferences in local overrides unless they are
  portable, intentional, and reviewed on every supported platform.

## Change quality

- Make the smallest coherent change that achieves the requested outcome.
- Verify the thing changed at the boundary where it will actually run.
- Preserve a recovery path before changing durable state.
- Record decisions in the repository or project where future agents need them,
  rather than relying on hidden provider memory.
