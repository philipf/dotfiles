---
name: chezmoi-sync
description: Report and sync chezmoi-managed dotfiles between this machine, the chezmoi source dir, and GitHub (philipf/dotfiles). Use when the user wants to sync dotfiles, check pending dotfile changes, or push/pull chezmoi changes between work and laptop machines.
---

# chezmoi-sync

Three-phase sync: **report → decide → sync**. Never skip the report phase, and never run sync actions the user hasn't selected.

**Hard gate:** the rendered report (summary line + table from Phase 1) MUST appear as visible output to the user BEFORE any AskUserQuestion call. This holds even when the plan seems obvious, the user pre-named the files to sync, or there is only one change — the user decides from the interpreted report, not from raw script output or your internal reading of it.

If the user passed arguments naming files (e.g. `add ~/.config/foo`), treat those as new files to `chezmoi add` in Phase 3.

## Phase 1 — Report

Run the helper script (it does `git fetch` and gathers everything in one shot):

```bash
bash ~/.claude/skills/chezmoi-sync/report.sh
```

From its output, render:

1. A summary line: `Sync summary: N to push up · M to pull down · K conflicts`
2. A table:

| File | What changed | Source | Git | vs GitHub | Suggestion |
|------|--------------|--------|-----|-----------|------------|

**Diff direction — read carefully:** the script runs `chezmoi diff --reverse`, so in the "home vs source" diff section `+` lines are the current HOME file (the user's local edits) and `-` lines are the SOURCE state. Describe local edits from the `+` lines. (Plain `chezmoi diff` is apply-direction, the opposite — never use it for describing local edits.) For incoming changes the "incoming from GitHub" git diff is normal direction: `+` = what pull/apply would bring in.

Column semantics:
- **What changed** — a one-sentence description you write from the diff sections, respecting the diff direction above.
- **Source** — home vs source dir: `modified` (home edited since last apply — chezmoi status col 1), `apply pending` (source ahead of home — col 2), or `in sync`.
- **Git** — `modified` if the file has uncommitted changes in the source dir, else `clean`.
- **vs GitHub** — `ahead ↑` (in an outgoing commit), `behind ↓` (in an incoming commit), or `in sync`.

Suggestion rules:
- home modified, GitHub untouched → `re-add → commit`
- changed on GitHub, home untouched → `pull → apply`
- changed on both sides → `conflict`
- uncommitted in source only → `commit`
- committed but not pushed → `push`
- file backed by a `*.tmpl` source → append ⚠ template marker

Roll incoming/outgoing commits that touch a file into that file's row; if the branch is ahead/behind with no per-file overlap, note it under the table.

## Phase 2 — Decide

Only after the summary line and table have been shown (see hard gate above), ask via AskUserQuestion: **"Proceed with sync plan?"** — options: *Apply all suggestions* / *Let me pick* / *Abort*.

**Embed the report in the question** — text rendered in the same turn as the question dialog can fail to display, so the dialog must be self-sufficient:
- Put the summary counts in the question text itself, e.g. `Proceed with sync plan? (2 to push up · 0 to pull down · 0 conflicts)`
- Give EVERY option a `preview` containing the full report table (markdown), so the plan is visible inside the dialog no matter which option is focused.
- Use option descriptions for per-file one-liners when they fit.

- *Let me pick* → one multiSelect checklist per action group (re-add these / apply these / etc.).
- If no new files were passed as args, ask conversationally whether there are new files to `chezmoi add` only when it seems relevant — don't block the fast path.

**Conflicts** (changed both locally and on GitHub, or `MM` divergence): one question per file, showing both diffs first — options: *Merge both* / *Keep local* / *Take remote* / *Skip*.
- *Merge both* = you edit the source file to combine both changes, show the result, and continue. If the merge is too tangled, suggest the user run `! chezmoi merge <file>` themselves.

**Template guard:** NEVER `chezmoi re-add` a file whose source is `*.tmpl` — re-add silently replaces the template with this machine's rendered output. Offer `chezmoi merge` or edit the `.tmpl` source directly instead.

## Phase 3 — Sync (rebase flow)

Run only the selected items, in this order (use `chezmoi git --` or `git -C "$(chezmoi source-path)"`):

1. `chezmoi add <new files>` and `chezmoi re-add <selected files>` (never templates)
2. Commit: subject summarizing the dominant change; body bullets reusing the per-file one-liners; end the body with `(synced from <hostname>)`. Example:

   ```
   Add screenshot keybind, allow new calc perms

   - .config/hypr/bindings.conf: bind Super+S to hyprshot
   - .claude/skills/settings.local.json: allow qalc commands

   (synced from F5-LAPTOP-2764)
   ```

3. `git pull --rebase` (if behind)
4. Resolve any rebase conflicts according to the per-file decisions from Phase 2
5. `chezmoi apply <remote-changed files>` — only the selected ones
6. `git push`

Pull-only syncs (nothing local to commit) skip steps 1–2 and 6.

Afterwards, run `chezmoi status` and `git -C "$(chezmoi source-path)" status --short --branch` to confirm clean, and show a final one-line summary of what was synced.
