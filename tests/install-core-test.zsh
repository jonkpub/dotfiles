#!/bin/zsh

emulate -LR zsh
setopt errexit nounset pipefail

ROOT="${0:A:h:h}"
INSTALLER="$ROOT/bin/install-core"
TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/install-core-test.XXXXXX")"
TEMP_ROOT="${TEMP_ROOT:A}"
trap 'rm -rf -- "$TEMP_ROOT"' EXIT INT TERM

fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

assert_missing() {
  [[ ! -e "$1" && ! -L "$1" ]] || fail "expected missing: $1"
}

assert_owned_link() {
  local target="$1"
  local source="$2"
  [[ -L "$target" ]] || fail "expected symlink: $target"
  [[ "${target:A}" == "${source:A}" ]] || fail "unexpected link target for: $target"
}

make_minimal_source() {
  local destination="$1" source_file relative_path
  mkdir -p -- "$destination"
  for relative_path in AGENTS.md bin/refresh-system-map profiles/common/zsh/.zshenv profiles/common/zsh/.zprofile profiles/common/zsh/.profile profiles/common/zsh/.zshrc profiles/common/git/.gitconfig profiles/common/tmux/.tmux.conf profiles/common/bash/workflow.bash profiles/darwin/Brewfile profiles/linux/packages.txt profiles/omarchy/packages.txt config/starship.toml config/atuin/config.toml config/broot/conf.hjson config/broot/verbs.hjson config/workstation/organization.md; do
    source_file="$ROOT/$relative_path"
    mkdir -p -- "$destination/${relative_path:h}"
    cp "$source_file" "$destination/$relative_path"
  done
  chmod +x "$destination/bin/refresh-system-map"
  git -C "$destination" init -q
  git -C "$destination" config user.name 'install-core test'
  git -C "$destination" config user.email 'install-core-test@example.invalid'
  git -C "$destination" add -A
  git -C "$destination" commit -qm 'fixture'
}

test_home="$TEMP_ROOT/home"
mkdir -p -- "$test_home"

HOME="$test_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$INSTALLER" >"$TEMP_ROOT/dry-run.out"
assert_missing "$test_home/AGENTS.md"
assert_missing "$test_home/.zshenv"
assert_missing "$test_home/.config"
grep -Fq 'Dry run complete; no files were changed.' "$TEMP_ROOT/dry-run.out" || fail "missing dry-run confirmation"
grep -Fq "MKDIR   $test_home/.local" "$TEMP_ROOT/dry-run.out" || fail "dry run did not plan local state directory"
grep -Fq "MKDIR   $test_home/.local/share" "$TEMP_ROOT/dry-run.out" || fail "dry run did not plan local share directory"
grep -Fq "MKDIR   $test_home/.local/share/workstation" "$TEMP_ROOT/dry-run.out" || fail "dry run did not plan workstation directory"
grep -Fq "CHMOD   700 $test_home/.local/share/workstation" "$TEMP_ROOT/dry-run.out" || fail "dry run did not plan workstation permissions"
grep -Fq "CREATE  $test_home/.local/share/workstation/SYSTEM_MAP.md" "$TEMP_ROOT/dry-run.out" || fail "dry run did not plan map creation"
assert_missing "$test_home/.local"

HOME="$test_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$INSTALLER" --apply >"$TEMP_ROOT/apply.out"
assert_owned_link "$test_home/AGENTS.md" "$ROOT/AGENTS.md"
assert_owned_link "$test_home/.zshenv" "$ROOT/profiles/common/zsh/.zshenv"
assert_owned_link "$test_home/.zprofile" "$ROOT/profiles/common/zsh/.zprofile"
assert_owned_link "$test_home/.profile" "$ROOT/profiles/common/zsh/.profile"
assert_owned_link "$test_home/.zshrc" "$ROOT/profiles/common/zsh/.zshrc"
assert_owned_link "$test_home/.config/dotfiles/git/portable.gitconfig" "$ROOT/profiles/common/git/.gitconfig"
[[ -f "$test_home/.gitconfig" && ! -L "$test_home/.gitconfig" ]] || fail "expected writable local Git wrapper"
grep -Fq '# managed-by: dotfiles-git-wrapper-v1' "$test_home/.gitconfig" || fail "missing Git wrapper ownership marker"
cp "$ROOT/profiles/common/git/.gitconfig" "$TEMP_ROOT/original-portable-gitconfig"
HOME="$test_home" git config --global user.email 'install-core-test@example.invalid' || fail "normal global Git write failed"
cmp -s "$TEMP_ROOT/original-portable-gitconfig" "$ROOT/profiles/common/git/.gitconfig" || fail "global Git write changed portable tracked configuration"
grep -Fq 'install-core-test@example.invalid' "$test_home/.gitconfig" || fail "global Git write did not stay in local wrapper"
assert_owned_link "$test_home/.tmux.conf" "$ROOT/profiles/common/tmux/.tmux.conf"
assert_owned_link "$test_home/.config/starship.toml" "$ROOT/config/starship.toml"
assert_owned_link "$test_home/.config/atuin/config.toml" "$ROOT/config/atuin/config.toml"
assert_owned_link "$test_home/.config/broot/conf.hjson" "$ROOT/config/broot/conf.hjson"
assert_owned_link "$test_home/.config/broot/verbs.hjson" "$ROOT/config/broot/verbs.hjson"
assert_missing "$test_home/.codex"
assert_missing "$test_home/.ssh"
assert_missing "$test_home/.config/opencode"
assert_missing "$test_home/.config/ws-guardian"
assert_missing "$test_home/Library/LaunchAgents"
assert_missing "$test_home/.local/bin/node"
[[ -f "$test_home/.local/share/workstation/SYSTEM_MAP.md" ]] || fail "expected refreshed system map"
grep -Fq '<!-- managed-by: dotfiles-system-map-v1 -->' "$test_home/.local/share/workstation/SYSTEM_MAP.md" || fail "missing system-map ownership marker"
grep -Fq '## Organization policy' "$test_home/.local/share/workstation/SYSTEM_MAP.md" || fail "missing organization policy section"
grep -Fq '### Project lifecycle' "$test_home/.local/share/workstation/SYSTEM_MAP.md" || fail "missing embedded organization-policy heading"
if rg -q '^# Organization Policy$' "$test_home/.local/share/workstation/SYSTEM_MAP.md"; then
  fail "organization policy resets rendered Markdown heading hierarchy"
fi
grep -Fq 'Projects/_scratch/YYYY-MM-topic' "$test_home/.local/share/workstation/SYSTEM_MAP.md" || fail "missing temporary-project placement guidance"
grep -Fq 'never automatically sweep or reorganize them' "$test_home/.local/share/workstation/SYSTEM_MAP.md" || fail "missing inbox safety guidance"
if SENTINEL_WORKSTATION_SECRET='do-not-render-this-value' HOME="$test_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$ROOT/bin/refresh-system-map" --apply >/dev/null; then
  if rg -Fq 'do-not-render-this-value' "$test_home/.local/share/workstation/SYSTEM_MAP.md"; then
    fail "system map rendered an environment secret sentinel"
  fi
else
  fail "system-map refresh failed during secret-sentinel check"
fi
if rg -q 'antigravity|PNPM_HOME|/opt/homebrew' "$ROOT/profiles/common/zsh"; then
  fail "portable core shell sources contain machine-specific runtime paths"
fi
if rg -Fq 'mkdir -p' "$ROOT/bin/install-core"; then
  fail "core installer still has non-atomic recursive directory creation"
fi

if command -v dash >/dev/null 2>&1; then
  dash -n "$ROOT/profiles/common/zsh/.profile" || fail "portable profile is not valid POSIX sh"
  HOME="$test_home" dash -c '. "$1"' dash "$ROOT/profiles/common/zsh/.profile" || fail "portable profile does not execute under dash"
fi

if command -v broot >/dev/null 2>&1 && command -v script >/dev/null 2>&1; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    script -q /dev/null broot --conf "$ROOT/config/broot/conf.hjson" --cmd :quit >/dev/null 2>&1 || fail "tracked broot configuration is not loadable"
  else
    script -q -c "TERM=xterm-256color broot --conf '$ROOT/config/broot/conf.hjson' --cmd :quit" /dev/null >/dev/null 2>&1 || fail "tracked broot configuration is not loadable"
  fi
fi
if rg -q 'skins/' "$ROOT/config/broot/conf.hjson"; then
  fail "public broot configuration references untracked skin files"
fi

HOME="$test_home" TERM=dumb zsh -ic 'exit' >"$TEMP_ROOT/zsh-dumb.out" 2>&1 || fail "portable Zsh startup failed with TERM=dumb"

fake_omarchy_bin="$TEMP_ROOT/fake-omarchy-bin"
mkdir -p -- "$fake_omarchy_bin"
print -- '#!/bin/sh' >"$fake_omarchy_bin/uname"
print -- 'printf "%s\\n" Linux' >>"$fake_omarchy_bin/uname"
print -- '#!/bin/sh' >"$fake_omarchy_bin/omarchy"
print -- 'exit 0' >>"$fake_omarchy_bin/omarchy"
chmod +x "$fake_omarchy_bin/uname" "$fake_omarchy_bin/omarchy"

omarchy_profile_home="$TEMP_ROOT/omarchy-profile-home"
mkdir -p -- "$omarchy_profile_home/.config/hypr"
print -- 'keep this desktop state' >"$omarchy_profile_home/.config/hypr/keep"
{
  print -- '[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap'
  print -- '[[ $- != *i* ]] && return'
  print -- '[[ -n "${OMARCHY_PATH:-}" && -r "$OMARCHY_PATH/default/bash/rc" ]] && source "$OMARCHY_PATH/default/bash/rc"'
  print -- 'alias omarchy-user-alias="printf preserved"'
} >"$omarchy_profile_home/.bashrc"
cp "$omarchy_profile_home/.bashrc" "$TEMP_ROOT/original-omarchy-bashrc"
PATH="$fake_omarchy_bin:$PATH" HOME="$omarchy_profile_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$INSTALLER" --profile omarchy >"$TEMP_ROOT/omarchy-profile.out"
grep -Fq 'selected profile: omarchy' "$TEMP_ROOT/omarchy-profile.out" || fail "missing explicit Omarchy profile selection"
assert_missing "$omarchy_profile_home/AGENTS.md"
grep -Fq 'package reference: profiles/omarchy/packages.txt (not installed by this command)' "$TEMP_ROOT/omarchy-profile.out" || fail "missing Omarchy package-reference plan"
PATH="$fake_omarchy_bin:$PATH" HOME="$omarchy_profile_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$INSTALLER" --profile omarchy --apply >"$TEMP_ROOT/omarchy-apply.out"
cmp -s "$TEMP_ROOT/original-omarchy-bashrc" "$omarchy_profile_home/.bashrc" || fail "existing Omarchy Bash entrypoint was changed"
assert_owned_link "$omarchy_profile_home/.local/share/dotfiles/bash/workflow.bash" "$ROOT/profiles/common/bash/workflow.bash"
assert_missing "$omarchy_profile_home/.zshrc"
assert_missing "$omarchy_profile_home/.profile"
grep -Fq 'keep this desktop state' "$omarchy_profile_home/.config/hypr/keep" || fail "Omarchy desktop state was changed"
PATH="$fake_omarchy_bin:$PATH" HOME="$omarchy_profile_home" TERM=xterm-256color bash --noprofile --norc -ic '. "$HOME/.local/share/dotfiles/bash/workflow.bash"' >"$TEMP_ROOT/omarchy-bash.out" 2>&1 || fail "managed Omarchy Bash workflow did not source"

if HOME="$test_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$INSTALLER" --profile linux >"$TEMP_ROOT/profile-mismatch.out" 2>&1; then
  fail "expected profile mismatch rejection"
fi
grep -Fq 'does not match this workstation' "$TEMP_ROOT/profile-mismatch.out" || fail "missing profile-mismatch rejection"

map_directory="$test_home/.local/share/workstation"
HOME="$test_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$ROOT/bin/refresh-system-map" --check >"$TEMP_ROOT/refresh-existing-check.out"
grep -Fq "REFRESH $test_home/.local/share/workstation/SYSTEM_MAP.md" "$TEMP_ROOT/refresh-existing-check.out" || fail "existing map preflight did not report refresh"
if grep -Fq 'CHMOD   700' "$TEMP_ROOT/refresh-existing-check.out"; then
  fail "existing map preflight planned an unnecessary mode change"
fi
chmod 755 "$map_directory"
HOME="$test_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$ROOT/bin/refresh-system-map" --apply >"$TEMP_ROOT/refresh-existing-dir.out"
if stat -f '%Lp' "$map_directory" >/dev/null 2>&1; then
  map_mode="$(stat -f '%Lp' "$map_directory")"
else
  map_mode="$(stat -c '%a' "$map_directory")"
fi
if [[ "$map_mode" != '755' ]]; then
  fail "refresh changed permissions on an existing map directory"
fi

HOME="$test_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$INSTALLER" --apply >"$TEMP_ROOT/reapply.out"
grep -Fq 'KEEP    [provider-neutral agent context]' "$TEMP_ROOT/reapply.out" || fail "missing idempotence output"

existing_git_home="$TEMP_ROOT/existing-git-home"
mkdir -p -- "$existing_git_home"
print -- '[user]' >"$existing_git_home/.gitconfig"
print -- '    name = Existing User' >>"$existing_git_home/.gitconfig"
cp "$existing_git_home/.gitconfig" "$TEMP_ROOT/original-existing-gitconfig"
HOME="$existing_git_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$INSTALLER" --apply >"$TEMP_ROOT/existing-git.out"
cmp -s "$TEMP_ROOT/original-existing-gitconfig" "$existing_git_home/.gitconfig" || fail "existing global Git config was changed"
assert_owned_link "$existing_git_home/.config/dotfiles/git/portable.gitconfig" "$ROOT/profiles/common/git/.gitconfig"
grep -Fq 'PRESERVE [Git global wrapper]' "$TEMP_ROOT/existing-git.out" || fail "existing Git config was not explicitly preserved"

conflict_home="$TEMP_ROOT/conflict-home"
mkdir -p -- "$conflict_home"
print -- 'user tmux config' >"$conflict_home/.tmux.conf"
if HOME="$conflict_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$INSTALLER" --apply >"$TEMP_ROOT/conflict.out" 2>&1; then
  fail "expected conflict to fail"
fi
assert_missing "$conflict_home/AGENTS.md"
grep -Fq 'no changes were made.' "$TEMP_ROOT/conflict.out" || fail "missing conflict safety confirmation"

relative_home="$TEMP_ROOT/relative-home"
mkdir -p -- "$relative_home"
if HOME="$relative_home" DOTFILES_SOURCE_DIR='relative/path' zsh "$INSTALLER" >"$TEMP_ROOT/relative.out" 2>&1; then
  fail "expected relative source rejection"
fi
grep -Fq 'must be an absolute path' "$TEMP_ROOT/relative.out" || fail "missing relative-source rejection"

nested_source="$TEMP_ROOT/nested-source"
make_minimal_source "$nested_source"
mkdir -p -- "$nested_source/child/config/workstation"
cp "$nested_source/AGENTS.md" "$nested_source/child/AGENTS.md"
cp "$nested_source/config/workstation/organization.md" "$nested_source/child/config/workstation/organization.md"
nested_source_home="$TEMP_ROOT/nested-source-home"
mkdir -p -- "$nested_source_home"
if HOME="$nested_source_home" DOTFILES_SOURCE_DIR="$nested_source/child" zsh "$ROOT/bin/refresh-system-map" --check >"$TEMP_ROOT/nested-source.out" 2>&1; then
  fail "expected nested source rejection"
fi
grep -Fq 'must be the Git worktree root' "$TEMP_ROOT/nested-source.out" || fail "missing nested-source rejection"

relative_home="$TEMP_ROOT/relative-home"
if HOME='relative-home' DOTFILES_SOURCE_DIR="$ROOT" zsh "$INSTALLER" >"$TEMP_ROOT/relative-home.out" 2>&1; then
  fail "expected relative HOME rejection"
fi
grep -Fq 'absolute, canonical, non-root' "$TEMP_ROOT/relative-home.out" || fail "missing relative-HOME rejection"

foreign_map_home="$TEMP_ROOT/foreign-map-home"
mkdir -p -- "$foreign_map_home/.local/share/workstation"
print -- '# a user-owned map' >"$foreign_map_home/.local/share/workstation/SYSTEM_MAP.md"
if HOME="$foreign_map_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$INSTALLER" --apply >"$TEMP_ROOT/foreign-map.out" 2>&1; then
  fail "expected foreign map rejection"
fi
grep -Fq '# a user-owned map' "$foreign_map_home/.local/share/workstation/SYSTEM_MAP.md" || fail "foreign map was changed"
assert_missing "$foreign_map_home/AGENTS.md"
grep -Fq 'non-owned system map' "$TEMP_ROOT/foreign-map.out" || fail "missing foreign-map rejection"

legacy_map_home="$TEMP_ROOT/legacy-map-home"
legacy_map="$legacy_map_home/.local/share/workstation/SYSTEM_MAP.md"
mkdir -p -- "${legacy_map:h}"
{
  print '# System Map'
  print 'Map scope: local, private, and safe for ordinary agent context.'
  print '## Current workstation'
  print '## File and project placement'
  print '## Working rules'
  print '## Refresh policy'
} >"$legacy_map"
if HOME="$legacy_map_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$ROOT/bin/refresh-system-map" --check >"$TEMP_ROOT/legacy-check.out" 2>&1; then
  fail "expected ordinary refresh to reject legacy map"
fi
HOME="$legacy_map_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$ROOT/bin/refresh-system-map" --adopt-legacy >"$TEMP_ROOT/legacy-adopt.out"
grep -Fq '<!-- managed-by: dotfiles-system-map-v1 -->' "$legacy_map" || fail "legacy adoption did not add marker"
grep -Fq '## Refresh policy' "$legacy_map" || fail "legacy adoption did not preserve content"
grep -Fq 'ADOPT ' "$TEMP_ROOT/legacy-adopt.out" || fail "legacy adoption did not report action"

ancestor_home="$TEMP_ROOT/unsafe-ancestor-home"
mkdir -p -- "$ancestor_home" "$TEMP_ROOT/foreign-directory"
ln -s "$TEMP_ROOT/foreign-directory" "$ancestor_home/.local"
if HOME="$ancestor_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$INSTALLER" >"$TEMP_ROOT/unsafe-ancestor.out" 2>&1; then
  fail "expected unsafe ancestor rejection"
fi
assert_missing "$ancestor_home/AGENTS.md"
grep -Fq 'unsafe output directory ancestor' "$TEMP_ROOT/unsafe-ancestor.out" || fail "missing unsafe-ancestor rejection"

if HOME="$test_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$ROOT/bin/refresh-system-map" --bogus >"$TEMP_ROOT/refresh-bogus.out" 2>&1; then
  fail "expected refresher argument rejection"
fi
grep -Fq 'unknown option' "$TEMP_ROOT/refresh-bogus.out" || fail "missing refresher argument rejection"

if HOME="$test_home" DOTFILES_SOURCE_DIR="$ROOT" zsh "$INSTALLER" --apply --dry-run >"$TEMP_ROOT/too-many-args.out" 2>&1; then
  fail "expected installer argument-count rejection"
fi
grep -Fq 'choose only one of --dry-run or --apply' "$TEMP_ROOT/too-many-args.out" || fail "missing installer mode-conflict rejection"

failure_source="$TEMP_ROOT/failure-source"
make_minimal_source "$failure_source"
{
  print '#!/bin/zsh'
  print '[[ "$1" == "--check" ]] && exit 0'
  print 'exit 97'
} >"$failure_source/bin/refresh-system-map"
chmod +x "$failure_source/bin/refresh-system-map"
failure_home="$TEMP_ROOT/failure-home"
mkdir -p -- "$failure_home"
if HOME="$failure_home" DOTFILES_SOURCE_DIR="$failure_source" zsh "$INSTALLER" --apply >"$TEMP_ROOT/refresh-failure.out" 2>&1; then
  fail "expected refresh failure"
fi
assert_missing "$failure_home/AGENTS.md"
assert_missing "$failure_home/.zshenv"
assert_missing "$failure_home/.config"
assert_missing "$failure_home/.gitconfig"
grep -Fq 'rolling back links created by this run' "$TEMP_ROOT/refresh-failure.out" || fail "missing rollback confirmation"

worktree_repo="$TEMP_ROOT/worktree-repo"
make_minimal_source "$worktree_repo"
worktree_source="$TEMP_ROOT/worktree-source"
git -C "$worktree_repo" worktree add --detach -q "$worktree_source" HEAD
[[ -f "$worktree_source/.git" ]] || fail "fixture is not a linked Git worktree"
worktree_home="$TEMP_ROOT/worktree-home"
mkdir -p -- "$worktree_home"
HOME="$worktree_home" DOTFILES_SOURCE_DIR="$worktree_source" zsh "$INSTALLER" --apply >"$TEMP_ROOT/worktree.out"
assert_owned_link "$worktree_home/AGENTS.md" "$worktree_source/AGENTS.md"
[[ -f "$worktree_home/.local/share/workstation/SYSTEM_MAP.md" ]] || fail "worktree source did not refresh map"

untracked_source="$TEMP_ROOT/untracked-source"
make_minimal_source "$untracked_source"
git -C "$untracked_source" rm --cached -q config/broot/verbs.hjson
untracked_home="$TEMP_ROOT/untracked-home"
mkdir -p -- "$untracked_home"
if HOME="$untracked_home" DOTFILES_SOURCE_DIR="$untracked_source" zsh "$INSTALLER" >"$TEMP_ROOT/untracked-source.out" 2>&1; then
  fail "expected untracked manifest source rejection"
fi
grep -Fq 'regular tracked file' "$TEMP_ROOT/untracked-source.out" || fail "missing untracked-source rejection"

symlink_source="$TEMP_ROOT/symlink-source"
make_minimal_source "$symlink_source"
rm "$symlink_source/config/starship.toml"
ln -s "$TEMP_ROOT/not-a-core-source.toml" "$symlink_source/config/starship.toml"
symlink_home="$TEMP_ROOT/symlink-home"
mkdir -p -- "$symlink_home"
if HOME="$symlink_home" DOTFILES_SOURCE_DIR="$symlink_source" zsh "$INSTALLER" >"$TEMP_ROOT/symlink-source.out" 2>&1; then
  fail "expected symlink manifest source rejection"
fi
grep -Fq 'regular tracked file' "$TEMP_ROOT/symlink-source.out" || fail "missing symlink-source rejection"

print -- 'install-core tests: PASS'
