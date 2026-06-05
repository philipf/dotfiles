#!/usr/bin/env bash
# Gathers all chezmoi sync state in one shot for the chezmoi-sync skill.
# Output is structured for Claude to render the sync report table.
set -uo pipefail

SRC=$(chezmoi source-path)
BRANCH=$(git -C "$SRC" rev-parse --abbrev-ref HEAD)
UPSTREAM="origin/$BRANCH"

section() { printf '\n== %s ==\n' "$1"; }

section "HOST"
hostname

section "FETCH"
if git -C "$SRC" fetch origin 2>&1; then
  echo "fetch ok"
else
  echo "FETCH FAILED (offline?) — 'vs GitHub' data below may be stale"
fi

section "AHEAD/BEHIND ($BRANCH vs $UPSTREAM)"
git -C "$SRC" rev-list --left-right --count "$BRANCH...$UPSTREAM" \
  | awk '{print "ahead: " $1 "   behind: " $2}'

section "CHEZMOI STATUS (col1: home changed since apply → re-add candidate; col2: apply would change)"
chezmoi status

section "SOURCE GIT STATUS (uncommitted in source dir)"
git -C "$SRC" status --short

section "OUTGOING COMMITS (local, not on GitHub)"
git -C "$SRC" log --oneline "$UPSTREAM..$BRANCH"

section "INCOMING COMMITS (on GitHub, not local)"
git -C "$SRC" log --oneline "$BRANCH..$UPSTREAM"

section "DIFF: source vs home (what 'chezmoi apply' would change; reversed = local edits)"
chezmoi diff 2>/dev/null | head -400

section "DIFF: uncommitted source changes"
git -C "$SRC" diff HEAD | head -400

section "DIFF: incoming from GitHub"
git -C "$SRC" diff "$BRANCH...$UPSTREAM" | head -400

section "TEMPLATE SOURCES (never re-add these targets)"
find "$SRC" -name '*.tmpl' -not -path "$SRC/.git/*"

section "END"
