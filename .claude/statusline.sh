#!/usr/bin/env bash
# Claude Code status line: model | context usage | session tokens & cost.
# Receives the session JSON on stdin (see code.claude.com/docs/en/statusline.md).

input=$(cat)

IFS=$'\t' read -r model used_pct win_size in_tok out_tok exceeds cost <<<"$(printf '%s' "$input" | jq -r '
  [ .model.display_name // "?",
    (.context_window.used_percentage // 0),
    (.context_window.context_window_size // 200000),
    (.context_window.total_input_tokens // 0),
    (.context_window.total_output_tokens // 0),
    (.exceeds_200k_tokens // false),
    (.cost.total_cost_usd // 0)
  ] | @tsv')"

# Human-readable token counts (e.g. 15.5k).
fmt() {
  awk -v n="$1" 'BEGIN{
    if (n>=1000000) printf "%.1fM", n/1000000;
    else if (n>=1000) printf "%.1fk", n/1000;
    else printf "%d", n;
  }'
}

win_k=$(awk -v n="$win_size" 'BEGIN{printf "%dk", n/1000}')
ctx="ctx ${used_pct}% of ${win_k}"
[ "$exceeds" = "true" ] && ctx="${ctx} ⚠️"

toks="↑$(fmt "$in_tok") ↓$(fmt "$out_tok")"
usd=$(awk -v c="$cost" 'BEGIN{printf "$%.2f", c}')

printf '%s │ %s │ %s │ %s' "$model" "$ctx" "$toks" "$usd"
