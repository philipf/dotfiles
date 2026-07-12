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
#
# The pristine base format is cached once per window (in @attn-base-fmt /
# @attn-base-fmt-cur) the first time this hook touches the window, and every
# call rebuilds from that cached base rather than from the live tmux option.
# Reading the live option would pick up whatever a *previous* call already
# injected (marker + color wrapper), and since the injected text itself
# contains "#W", each subsequent call would nest another marker inside the
# last one's color wrapper instead of replacing it -- markers pile up and a
# color set by "waiting" never gets cleared by a later "busy".
get_base() {
  local opt="$1" cache="$2" fallback="$3"
  local val
  val=$(tmux show-window-options -t "$win" -qv "$cache" 2>/dev/null)
  if [ -z "$val" ]; then
    val=$(tmux show-options -gqv "$opt")
    [ -z "$val" ] && val="$fallback"
    tmux set-window-option -t "$win" "$cache" "$val" 2>/dev/null
  fi
  printf '%s' "$val"
}

set_mark() {
  local marker="$1" color="$2"
  local base_fmt base_cur namefmt
  base_fmt=$(get_base window-status-format @attn-base-fmt '#I:#W#{?window_flags,#{window_flags}, }')
  base_cur=$(get_base window-status-current-format @attn-base-fmt-cur "$base_fmt")
  if [ -n "$color" ]; then
    namefmt="#[fg=$color]#W$marker#[default]"
  else
    namefmt="#W$marker"
  fi
  tmux set-window-option -t "$win" window-status-format "${base_fmt//\#W/$namefmt}" 2>/dev/null
  tmux set-window-option -t "$win" window-status-current-format "${base_cur//\#W/$namefmt}" 2>/dev/null
}

case "$1" in
  waiting|on) set_mark '🤖' red ;;
  busy)       set_mark '⏳' '' ;;
  off)
    tmux set-window-option -t "$win" -u window-status-format 2>/dev/null
    tmux set-window-option -t "$win" -u window-status-current-format 2>/dev/null
    tmux set-window-option -t "$win" -u @attn-base-fmt 2>/dev/null
    tmux set-window-option -t "$win" -u @attn-base-fmt-cur 2>/dev/null
    ;;
esac

# Force an immediate status-line repaint. Without this, the option change above
# only becomes visible on the next `status-interval` tick (or an incidental
# redraw), which looks like the hook "didn't run". -S refreshes the status line
# of every attached client.
tmux refresh-client -S 2>/dev/null

exit 0
