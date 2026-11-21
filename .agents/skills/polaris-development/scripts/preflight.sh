#!/usr/bin/env bash
set -euo pipefail

usage() {
    printf 'Usage: %s [--base <ref>] [keywords...]\n' "${0##*/}"
}

base=''
if [[ "${1:-}" == "--allow-dirty" ]]; then
    # Older callers used this option for audits. All runs now accept local changes.
    shift
fi

case "${1:-}" in
    --base)
        if [[ -z "${2:-}" || "$2" == -* ]]; then
            usage >&2
            exit 2
        fi
        base="$2"
        shift 2
        ;;
    -h|--help)
        usage
        exit 0
        ;;
esac

if ! repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    printf 'Run inside a Polaris Git worktree.\n' >&2
    exit 2
fi
cd "$repo_root"

if [[ -z "$base" ]]; then
    base="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD || true)"
    if [[ -z "$base" ]] && git show-ref --verify --quiet refs/remotes/origin/main; then
        base='origin/main'
    fi
fi

branch="$(git branch --show-current)"
printf 'Repository: %s\nBranch: %s\nHEAD: %s\n' "$repo_root" "${branch:-DETACHED}" "$(git rev-parse HEAD)"
if [[ -n "$base" ]]; then
    if ! base_sha="$(git rev-parse --verify --end-of-options "$base^{commit}")"; then
        printf 'Base ref unavailable locally: %s\n' "$base" >&2
        exit 2
    fi
    read -r behind ahead < <(git rev-list --left-right --count "$base_sha...HEAD")
    printf 'Base (local): %s (%s)\nAhead/behind: %s/%s\n' "$base" "$base_sha" "$ahead" "$behind"
else
    printf 'Base: unavailable locally. Pass --base <ref> to compare with a known ref.\n'
fi

status="$(git status --porcelain=v1 --untracked-files=all)"
if [[ -n "$status" ]]; then
    printf 'Worktree changes:\n%s\n' "$status"
else
    printf 'Worktree: clean\n'
fi

if (($#)); then
    terms=()
    for keyword in "$@"; do
        terms+=("--grep=$keyword")
    done
    printf '\nRecent matching commits:\n'
    git log "${base_sha:-HEAD}" -i --oneline --fixed-strings "${terms[@]}" -n 20 --
fi
