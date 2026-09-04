#!/bin/zsh

emulate -LR zsh
setopt errexit nounset pipefail

ROOT="$0:A:h:h"
HELPER="$ROOT/bin/agent-context"
TEMP_ROOT="$(mktemp -d "$TMPDIR/agent-context-test.XXXXXX")"
TEMP_ROOT="$TEMP_ROOT:A"
trap 'rm -rf -- "$TEMP_ROOT"' EXIT INT TERM

fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

test_home="$TEMP_ROOT/home"
test_bin="$TEMP_ROOT/bin"
mkdir -p -- "$test_home" "$test_bin" "$test_home/.gemini"
touch "$test_bin/codex" "$test_bin/claude" "$test_bin/gemini" "$test_bin/opencode" "$test_bin/hermes"
chmod 700 "$test_bin"/*
print -- '# canonical context' >"$test_home/AGENTS.md"
print -- '# existing Gemini preferences' >"$test_home/.gemini/GEMINI.md"

HOME="$test_home" PATH="$test_bin:/opt/homebrew/bin:/usr/bin:/bin" /bin/zsh "$HELPER" --json >"$TEMP_ROOT/before.json"
rg -Fq '"id":"codex","available":true' "$TEMP_ROOT/before.json" || fail 'Codex detection missing'
rg -Fq '"id":"claude","available":true' "$TEMP_ROOT/before.json" || fail 'Claude detection missing'
rg -Fq '"adapterState":"missing","readiness":"adapter-needed"' "$TEMP_ROOT/before.json" || fail 'Claude adapter plan missing'
rg -Fq '"adapterState":"user-owned","readiness":"adapter-merge-needed"' "$TEMP_ROOT/before.json" || fail 'Gemini preservation state missing'

HOME="$test_home" PATH="$test_bin:/opt/homebrew/bin:/usr/bin:/bin" /bin/zsh "$HELPER" --apply >"$TEMP_ROOT/apply.out"
rg -Fq 'CREATE  [claude adapter]' "$TEMP_ROOT/apply.out" || fail 'Claude adapter was not created'
rg -Fq 'HOLD    [gemini adapter] existing user-owned file' "$TEMP_ROOT/apply.out" || fail 'Gemini file was not preserved'
rg -Fq '<!-- managed-by: workstation-agent-adapter-v1; adapter: claude -->' "$test_home/.claude/CLAUDE.md" || fail 'Claude marker missing'
[[ ! -e "$test_home/.local/state/workstation/agent-adapters/backups" ]] || fail 'unexpected Gemini backup before merge'

HOME="$test_home" PATH="$test_bin:/opt/homebrew/bin:/usr/bin:/bin" /bin/zsh "$HELPER" --apply --merge-existing >"$TEMP_ROOT/merge.out"
rg -Fq 'MERGED  [gemini adapter]' "$TEMP_ROOT/merge.out" || fail 'Gemini merge missing'
rg -Fq '<!-- managed-by: workstation-agent-adapter-v1; adapter: gemini -->' "$test_home/.gemini/GEMINI.md" || fail 'Gemini marker missing'
[[ -n "$(print -r -- "$test_home/.local/state/workstation/agent-adapters/backups"/gemini-*.md(N))" ]] || fail 'Gemini backup missing'

print -- 'agent-context tests: PASS'
