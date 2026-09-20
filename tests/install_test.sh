#!/usr/bin/env bash

set -euo pipefail

repository_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
temporary_root=$(mktemp -d "${TMPDIR:-/tmp}/my-agents-install-test.XXXXXX")
trap 'rm -rf -- "$temporary_root"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_file() {
  [[ -f "$1" ]] || fail "missing file: $1"
}

assert_same() {
  cmp -s -- "$1" "$2" || fail "files differ: $1 and $2"
}

if "$repository_root/install.sh" >"$temporary_root/no-argument.out" 2>&1; then
  fail "missing target argument should fail"
fi

target="$temporary_root/project with spaces"
"$repository_root/install.sh" "$target" >"$temporary_root/first.out"

assert_same "$repository_root/AGENTS.md" "$target/AGENTS.md"
assert_same "$repository_root/CLAUDE.md" "$target/CLAUDE.md"
assert_same "$repository_root/claude/settings.json" "$target/.claude/settings.json"
assert_same "$repository_root/claude/statusline.sh" "$target/.claude/statusline.sh"
assert_same "$repository_root/docs/index.md" "$target/docs/index.md"
[[ -x "$target/.claude/statusline.sh" ]] || fail "statusline.sh is not executable"

"$repository_root/install.sh" "$target" >"$temporary_root/second.out"
grep -q 'スキップ 0' "$temporary_root/second.out" || fail "second install should have no conflicts"

printf '利用者が変更した内容\n' >"$target/AGENTS.md"
"$repository_root/install.sh" "$target" >"$temporary_root/skip.out"
grep -q 'スキップ AGENTS.md' "$temporary_root/skip.out" || fail "changed file should be skipped"
grep -q '利用者が変更した内容' "$target/AGENTS.md" || fail "changed file was overwritten"

"$repository_root/install.sh" --backup "$target" >"$temporary_root/backup.out"
assert_same "$repository_root/AGENTS.md" "$target/AGENTS.md"
backup_file=$(find "$target" -maxdepth 1 -type f -name 'AGENTS.md.bak.*' -print -quit)
[[ -n "$backup_file" ]] || fail "backup was not created"
grep -q '利用者が変更した内容' "$backup_file" || fail "backup content is incorrect"

dry_run_target="$temporary_root/dry-run-project"
"$repository_root/install.sh" --dry-run "$dry_run_target" >"$temporary_root/dry-run.out"
[[ ! -e "$dry_run_target" ]] || fail "dry-run created the target directory"
grep -q '導入予定 AGENTS.md' "$temporary_root/dry-run.out" || fail "dry-run did not report planned files"

shell_modes=(sh bash-posix bash-posix-env)
if command -v dash >/dev/null 2>&1; then
  shell_modes+=(dash)
fi

for shell_mode in "${shell_modes[@]}"; do
  case "$shell_mode" in
    sh) installer_command=(sh "$repository_root/install.sh") ;;
    dash) installer_command=(dash "$repository_root/install.sh") ;;
    bash-posix) installer_command=(bash --posix "$repository_root/install.sh") ;;
    bash-posix-env) installer_command=(env POSIXLY_CORRECT=1 bash "$repository_root/install.sh") ;;
  esac

  shell_target="$temporary_root/$shell_mode project with spaces"
  "${installer_command[@]}" --dry-run "$shell_target" >"$temporary_root/$shell_mode-dry-run.out" 2>&1 || fail "$shell_mode dry-run failed"
  [[ ! -e "$shell_target" ]] || fail "$shell_mode dry-run created the target directory"
  grep -q '導入予定 docs/index.md' "$temporary_root/$shell_mode-dry-run.out" || fail "$shell_mode dry-run did not reach documentation files"

  "${installer_command[@]}" "$shell_target" >"$temporary_root/$shell_mode-install.out" 2>&1 || fail "$shell_mode install failed"
  assert_same "$repository_root/AGENTS.md" "$shell_target/AGENTS.md"
  assert_same "$repository_root/CLAUDE.md" "$shell_target/CLAUDE.md"
  assert_same "$repository_root/claude/settings.json" "$shell_target/.claude/settings.json"
  assert_same "$repository_root/docs/index.md" "$shell_target/docs/index.md"
done

printf 'PASS: install.sh の全テストに成功しました\n'
