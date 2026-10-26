#!/usr/bin/env bash
# Claude Code status line: repo | model | context usage | plan usage | lines changed.
# Receives the session JSON on stdin (see code.claude.com/docs/en/statusline.md).

input=$(cat)

IFS=$'\x1f' read -r cwd model used_pct win_size five_pct five_reset week_pct week_reset added removed <<<"$(printf '%s' "$input" | jq -r '
  [ .workspace.current_dir // .cwd // "",
    .model.display_name // "?",
    (.context_window.used_percentage // 0),
    (.context_window.context_window_size // 200000),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.five_hour.resets_at // ""),
    (.rate_limits.seven_day.used_percentage // ""),
    (.rate_limits.seven_day.resets_at // ""),
    (.cost.total_lines_added // 0),
    (.cost.total_lines_removed // 0)
  ] | map(tostring) | join("\u001f")')"

YELLOW=$'\e[33m'
RED=$'\e[31m'
RESET=$'\e[0m'

# Repo name, or the directory name outside a git repo. --no-optional-locks keeps
# a refresh from contending with a git command running in the same repo.
top=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
repo=$(basename "${top:-$cwd}")
if [ -n "$top" ]; then
  # Detached HEAD has no branch name; show the short commit instead.
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  case "$branch" in
    master|main) branch="${YELLOW}${branch}${RESET}" ;;
  esac
  repo="${repo} · ${branch}"
fi

pct=$(awk -v p="$used_pct" 'BEGIN{printf "%d", p}')
win_k=$(awk -v n="$win_size" 'BEGIN{printf "%dk", n/1000}')
ctx="ctx ${pct}% of ${win_k}"
if [ "$pct" -gt 95 ]; then ctx="${RED}${ctx}${RESET}"
elif [ "$pct" -gt 85 ]; then ctx="${YELLOW}${ctx}${RESET}"
fi

parts=("$repo" "$model" "$ctx")

# rate_limits is absent for API-key sessions and before the first response.
if [ -n "$five_pct" ] || [ -n "$week_pct" ]; then
  usage=""
  [ -n "$five_pct" ] && usage="5h $(awk -v p="$five_pct" 'BEGIN{printf "%d", p}')%"
  [ -n "$five_reset" ] && usage="${usage} (resets $(date -r "${five_reset%.*}" +%H:%M))"
  [ -n "$week_pct" ] && usage="${usage:+${usage} · }7d $(awk -v p="$week_pct" 'BEGIN{printf "%d", p}')%"
  [ -n "$week_reset" ] && usage="${usage} (resets $(date -r "${week_reset%.*}" '+%a %H:%M'))"
  parts+=("$usage")
fi

parts+=("+${added}/-${removed}")

out=""
for p in "${parts[@]}"; do out="${out:+${out} │ }${p}"; done
printf '%s' "$out"
