# Git Workflow

- Inspect `git status` and the current branch before changing an existing
  repository.
- Preserve unrelated user changes. Do not reset, discard, or fold them into an
  agent task without explicit scope.
- Use focused commits with a message that describes the actual change.
- Run proportionate verification before committing; record any known limits.
- Do not push, publish, open a pull request, or alter remotes merely because a
  repository has credentials available.
- Public repositories use only public-safe content. Secret scans and manifest
  review precede first publication and unusual bulk changes.
- Personal identity, signing, and credential settings belong in the local Git
  include, never in this public repository.
