This is a default placement policy for agent-created work. It is a map for
decisions, not an authority to move, rename, delete, or upload existing files.
Classify existing material before proposing a change. Preserve Git state,
references, and a reversible recovery path for every durable migration.

### Project lifecycle

- **Idea / disposable experiment:** use `~/Projects/_scratch/YYYY-MM-topic`.
  Include a short README and promote only when the work has a clear owner or
  durable purpose.
- **Prototype:** use `~/Projects/<area>/<project>` and initialize Git before
  the first meaningful implementation change. Keep generated builds and local
  credentials outside version control.
- **Active development:** keep the canonical repository under
  `~/Projects/<area>/<project>`. Use branches or worktrees for parallel work;
  do not copy a repository merely to create a new phase.
- **Testing / release:** keep CI, deployment manifests, and release notes in
  the same canonical repository. Do not treat Desktop, Downloads, or a chat
  workspace as a release source.
- **Archived project:** preserve the repository and concise ownership/status
  note. Archive or relocate only after checking references, remotes, Git
  status, and recovery needs.

`<area>` is a reusable, user-chosen domain rather than a rigid taxonomy. Use a
clear stable label such as `personal`, `client`, or `labs` when it helps group
related work; do not invent a new area solely to make one project look tidy.

### Personal material and media

- **Documents:** use `~/Documents/<area>` for durable personal material.
  Keep working source and final exports together only when that makes their
  relationship clear; otherwise use a documented project folder.
- **Images, audio, and video:** use the platform media library or
  `~/Pictures/<area>` for durable originals. Put generated derivatives beside
  the project that owns them or in a clearly named export folder.
- **Downloads and Desktop:** treat as reviewable inboxes. An agent may classify
  and propose destinations, but never automatically sweep or reorganize them.
- **Applications and tool state:** install applications through the platform's
  normal application location. Keep tool configuration in its documented
  config location or in the tracked dotfiles source; never use Documents or
  Downloads as a configuration store.

### Cross-machine and iCloud boundary

- iCloud is an Apple-native personal/archive layer, not the canonical home for
  cross-platform agent-managed repositories.
- `iCloud Drive/Agent Exchange` is a deliberate hand-off area only. Place
  copies there only when a task explicitly crosses the personal-iCloud and
  agent-managed boundaries.
- Before moving durable content across machines or storage systems, show a
  preview, check references and Git state, choose a recovery path, and obtain
  approval.
