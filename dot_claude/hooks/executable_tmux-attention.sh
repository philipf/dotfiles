#!/usr/bin/env bash
# Mark the tmux tab for the window running this Claude Code session:
#   tmux-attention.sh waiting  -> 🤖 + red name  (Claude is waiting on you)
#   tmux-attention.sh busy     -> ⏳ + normal name (Claude is working)
#   tmux-attention.sh off      -> revert to the normal tab
#
# Wired to Claude Code hooks: Stop/Notification -> waiting, UserPromptSubmit -> busy.

# Not in tmux? Nothing to do.
[ -z "$TMUX_PANE" ] && exit 0

win=$(tmux display-message -p -t "$TMUX_PANE" '#{window_id}' 2>/dev/null) || exit 0
[ -z "$win" ] && exit 0

# set_mark <marker> <color-or-empty>: inject "<color>#W<marker>#[default]" at #W
# in this window's tab formats, preserving the rest of the format.
set_mark() {
  local marker="$1" color="$2"
  local fmt cur namefmt
  fmt=$(tmux show-options -gqv window-status-format)
  cur=$(tmux show-options -gqv window-status-current-format)
  [ -z "$fmt" ] && fmt='#I:#W#{?window_flags,#{window_flags}, }'
  [ -z "$cur" ] && cur="$fmt"
  if [ -n "$color" ]; then
    namefmt="#[fg=$color]#W$marker#[default]"
  else
    namefmt="#W$marker"
  fi
  tmux set-window-option -t "$win" window-status-format "${fmt//\#W/$namefmt}" 2>/dev/null
  tmux set-window-option -t "$win" window-status-current-format "${cur//\#W/$namefmt}" 2>/dev/null
}

case "$1" in
  waiting|on) set_mark '🤖' red ;;
  busy)       set_mark '⏳' '' ;;
  off)
    tmux set-window-option -t "$win" -u window-status-format 2>/dev/null
    tmux set-window-option -t "$win" -u window-status-current-format 2>/dev/null
    ;;
esac

exit 0
