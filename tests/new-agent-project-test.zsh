#!/bin/zsh

emulate -LR zsh
setopt errexit nounset pipefail

ROOT="${0:A:h:h}"
HELPER="$ROOT/bin/new-agent-project"
TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/new-agent-project-test.XXXXXX")"
TEMP_ROOT="${TEMP_ROOT:A}"
trap 'rm -rf -- "$TEMP_ROOT"' EXIT INT TERM

fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

test_home="$TEMP_ROOT/home"
mkdir -p -- "$test_home"

HOME="$test_home" zsh "$HELPER" --kind scratch --name test-idea >"$TEMP_ROOT/scratch-dry-run.out"
[[ ! -e "$test_home/Projects" ]] || fail "scratch dry run changed the filesystem"
grep -Fq 'Dry run complete; no files were changed.' "$TEMP_ROOT/scratch-dry-run.out" || fail "missing scratch dry-run confirmation"

HOME="$test_home" zsh "$HELPER" --kind scratch --name test-idea --apply >"$TEMP_ROOT/scratch-apply.out"
scratch_target="$test_home/Projects/_scratch/$(date -u '+%Y-%m')-test-idea"
[[ -f "$scratch_target/README.md" ]] || fail "scratch README was not created"
[[ ! -d "$scratch_target/.git" ]] || fail "scratch project unexpectedly initialized Git"

HOME="$test_home" zsh "$HELPER" --kind project --area labs --name durable-test --apply >"$TEMP_ROOT/project-apply.out"
project_target="$test_home/Projects/labs/durable-test"
[[ -f "$project_target/README.md" ]] || fail "durable project README was not created"
[[ -d "$project_target/.git" ]] || fail "durable project did not initialize Git"

if HOME="$test_home" zsh "$HELPER" --kind project --area labs --name durable-test --apply >"$TEMP_ROOT/reuse.out" 2>&1; then
  fail "expected existing target refusal"
fi
grep -Fq 'target already exists' "$TEMP_ROOT/reuse.out" || fail "missing existing-target refusal"

if HOME="$test_home" zsh "$HELPER" --kind project --name 'Not A Slug' >"$TEMP_ROOT/slug.out" 2>&1; then
  fail "expected invalid-slug refusal"
fi
grep -Fq 'lowercase letters, digits, and hyphens' "$TEMP_ROOT/slug.out" || fail "missing invalid-slug refusal"

print -- 'new-agent-project tests: PASS'
