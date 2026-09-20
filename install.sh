#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

set +o posix
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./install.sh [--backup] [--dry-run] TARGET_DIRECTORY

指定したフォルダへエージェント設定テンプレートを導入します。

Options:
  --backup   内容が異なる既存ファイルを退避してから置換する
  --dry-run  ファイルを変更せず、実行予定だけを表示する
  -h, --help このヘルプを表示する
EOF
}

backup_enabled=false
dry_run=false
target_directory=""

while (($# > 0)); do
  case "$1" in
    --backup)
      backup_enabled=true
      ;;
    --dry-run)
      dry_run=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      if (($# != 1)) || [[ -n "$target_directory" ]]; then
        printf 'Error: exactly one target directory is required.\n' >&2
        usage >&2
        exit 2
      fi
      target_directory="$1"
      shift
      break
      ;;
    -*)
      printf 'Error: unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [[ -n "$target_directory" ]]; then
        printf 'Error: exactly one target directory is required.\n' >&2
        usage >&2
        exit 2
      fi
      target_directory="$1"
      ;;
  esac
  shift
done

if [[ -z "$target_directory" ]]; then
  printf 'Error: target directory is required.\n' >&2
  usage >&2
  exit 2
fi

script_directory=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

required_sources=(
  "$script_directory/AGENTS.md"
  "$script_directory/CLAUDE.md"
  "$script_directory/claude"
  "$script_directory/docs"
)

for required_source in "${required_sources[@]}"; do
  if [[ ! -e "$required_source" ]]; then
    printf 'Error: required template source is missing: %s\n' "$required_source" >&2
    exit 1
  fi
done

installed_count=0
unchanged_count=0
skipped_count=0
backup_count=0

make_backup_path() {
  local destination=$1
  local timestamp candidate suffix

  timestamp=$(date '+%Y%m%d%H%M%S')
  candidate="${destination}.bak.${timestamp}"
  suffix=1
  while [[ -e "$candidate" || -L "$candidate" ]]; do
    candidate="${destination}.bak.${timestamp}.${suffix}"
    ((suffix += 1))
  done
  printf '%s\n' "$candidate"
}

copy_atomically() {
  local source=$1
  local destination=$2
  local mode=$3
  local parent temporary

  parent=$(dirname -- "$destination")
  mkdir -p -- "$parent"
  temporary=$(mktemp "${destination}.tmp.XXXXXX")
  if ! cp -- "$source" "$temporary" || ! chmod "$mode" "$temporary" || ! mv -f -- "$temporary" "$destination"; then
    rm -f -- "$temporary"
    return 1
  fi
}

install_file() {
  local source=$1
  local relative_destination=$2
  local destination="$target_directory/$relative_destination"
  local mode=644
  local backup_path

  [[ -x "$source" ]] && mode=755

  if [[ -e "$destination" || -L "$destination" ]]; then
    if [[ -f "$destination" ]] && cmp -s -- "$source" "$destination"; then
      printf '同一     %s\n' "$relative_destination"
      ((unchanged_count += 1))
      return
    fi

    if [[ -d "$destination" && ! -L "$destination" ]]; then
      printf 'スキップ %s（同名のディレクトリが存在）\n' "$relative_destination"
      ((skipped_count += 1))
      return
    fi

    if [[ "$backup_enabled" != true ]]; then
      printf 'スキップ %s（内容が異なる既存ファイルを保護）\n' "$relative_destination"
      ((skipped_count += 1))
      return
    fi

    backup_path=$(make_backup_path "$destination")
    if [[ "$dry_run" == true ]]; then
      printf '退避予定 %s -> %s\n' "$relative_destination" "${backup_path#"$target_directory/"}"
      printf '置換予定 %s\n' "$relative_destination"
    else
      mv -- "$destination" "$backup_path"
      if ! copy_atomically "$source" "$destination" "$mode"; then
        mv -- "$backup_path" "$destination"
        printf 'Error: failed to install file: %s\n' "$relative_destination" >&2
        exit 1
      fi
      printf '退避     %s -> %s\n' "$relative_destination" "${backup_path#"$target_directory/"}"
      printf '置換     %s\n' "$relative_destination"
    fi
    ((backup_count += 1))
    ((installed_count += 1))
    return
  fi

  if [[ "$dry_run" == true ]]; then
    printf '導入予定 %s\n' "$relative_destination"
  else
    if ! copy_atomically "$source" "$destination" "$mode"; then
      printf 'Error: failed to install file: %s\n' "$relative_destination" >&2
      exit 1
    fi
    printf '導入     %s\n' "$relative_destination"
  fi
  ((installed_count += 1))
}

if [[ "$dry_run" != true ]]; then
  if [[ -e "$target_directory" && ! -d "$target_directory" ]]; then
    printf 'Error: target exists and is not a directory: %s\n' "$target_directory" >&2
    exit 1
  fi
  mkdir -p -- "$target_directory"
fi

install_file "$script_directory/AGENTS.md" "AGENTS.md"
install_file "$script_directory/CLAUDE.md" "CLAUDE.md"

while IFS= read -r source_path; do
  relative_path=${source_path#"$script_directory/claude/"}
  install_file "$source_path" ".claude/$relative_path"
done < <(find "$script_directory/claude" -type f -print | LC_ALL=C sort)

while IFS= read -r source_path; do
  relative_path=${source_path#"$script_directory/docs/"}
  install_file "$source_path" "docs/$relative_path"
done < <(find "$script_directory/docs" -type f -print | LC_ALL=C sort)

if [[ "$dry_run" == true ]]; then
  printf '\n確認完了: 導入・置換予定 %d、退避予定 %d、同一 %d、スキップ %d\n' \
    "$installed_count" "$backup_count" "$unchanged_count" "$skipped_count"
else
  printf '\n導入完了: 導入・置換 %d、退避 %d、同一 %d、スキップ %d\n' \
    "$installed_count" "$backup_count" "$unchanged_count" "$skipped_count"
fi
