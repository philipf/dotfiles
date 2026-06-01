#!/usr/bin/env bash
# Claude Code status line - mirrors Starship prompt style
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
effort_level=$(echo "$input" | jq -r '.effort.level // empty')

# Git branch (skip optional locks, suppress errors)
git_branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree --no-optional-locks 2>/dev/null | grep -q true; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
fi

# Build the status line using ANSI colors (dimmed-friendly)
RESET='\033[0m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'

line=""

# current directory (shorten home to ~)
short_cwd="${cwd/#$HOME/\~}"
line+=$(printf "${CYAN}%s${RESET}" "$short_cwd")

# git branch
if [ -n "$git_branch" ]; then
  line+=$(printf " ${MAGENTA}[%s]${RESET}" "$git_branch")
fi

# model
if [ -n "$model" ]; then
  line+=$(printf " ${BLUE}%s${RESET}" "$model")
fi

# Add thousand separators to an integer (portable, no locale dependency)
add_commas() {
  printf "%s" "$1" | sed ':a;s/\([0-9]\)\([0-9]\{3\}\)\b/\1,\2/;ta'
}

# context usage + token count
if [ -n "$used_pct" ]; then
  printf_pct=$(printf "%.0f" "$used_pct")
  ctx_str="ctx:${printf_pct}%"
  if [ -n "$total_tokens" ] && [ "$total_tokens" != "0" ]; then
    formatted_tokens=$(add_commas "$total_tokens")
    ctx_str="${ctx_str} (${formatted_tokens}tok)"
  fi
  line+=$(printf " ${YELLOW}%s${RESET}" "$ctx_str")
fi

# effort / mode indicator
if [ -n "$effort_level" ]; then
  case "$effort_level" in
    low)    mode_label="fast" ;;
    medium) mode_label="medium" ;;
    high)   mode_label="high" ;;
    xhigh)  mode_label="xhigh" ;;
    max)    mode_label="max" ;;
    *)      mode_label="$effort_level" ;;
  esac
  line+=$(printf " ${MAGENTA}[%s]${RESET}" "$mode_label")
fi

printf "%b\n" "$line"
