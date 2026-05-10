---
name: todo
description: Add a new item to the GTD inbox (## In section) of the Kanban board
---

The user wants to capture a new GTD inbox item. The item to capture is provided as the argument after `/todo`.

Count the words in the description to determine the path:

## Short description (10 words or fewer)

1. Open `~/SecondBrain/_GTD/_Board.md`
2. Insert `- [ ] <description>` as the first item under `## In` (immediately after the blank line following `## In`)
3. Do not modify any other part of the file
4. Confirm to the user that the item was added

Use the description exactly as provided — do not rephrase or reformat it.

## Long description (more than 10 words)

1. Summarise the description into a short title (3–6 words, title-case)
2. Create a new markdown note at `~/SecondBrain/Notes/<title>.md` using this exact template:

```
---
created: <YYYY-MM-DD HH:MM>
type: note
tags: ['']
aliases: ['']
---
# <title>

<full description as provided by the user>

```

3. Open `~/SecondBrain/_GTD/_Board.md`
4. Insert `- [ ] [[<title>]]` as the first item under `## In` (immediately after the blank line following `## In`)
5. Do not modify any other part of the file
6. Confirm to the user that the item and linked note were created, and show the title used
