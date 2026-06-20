---
name: reverse-caveman
description: Inverse of caveman — expand terse output into full natural-language prose. This is a manual style toggle, NOT a task helper. Activate ONLY when the user explicitly types /reverse-caveman (or asks to "undo caveman" / "expand mode"). Do not auto-invoke for ordinary work.
disable-model-invocation: true
---


# Reverse Caveman Specification v1.0

## Overview

This document defines the formal rules for Reverse Caveman: the inverse of [Caveman Compression](../caveman/SKILL.md). Where caveman strips linguistic overhead, Reverse Caveman restores it — re-inflating terse, telegraphic text into flowing, fully-grammatical prose.

**Design Goal**: Maximize readability and rhetorical completeness while preserving the exact information content.

**Core Principle**: Restore only what an LLM can deterministically reconstruct — grammar, connectives, articles, transitions, and rhetorical framing. NEVER introduce facts, numbers, claims, or justifications that were not present. We re-add the linguistic packaging; we do not invent content.

**Relationship to caveman**: Caveman is lossy on *surface form* but lossless on *facts*. Reverse Caveman therefore can never reproduce the exact original wording — only faithfully rebuild meaning and grammar. The two are opposite poles of one style axis.

**Activation**: This is a persistent **mode**. Once invoked, ALL subsequent prose output is rendered in expanded form until the user says to stop (e.g. "normal mode", "stop expanding", "enough"). Invoke only via the explicit slash command.

---

## Core Rules

Each rule is the inverse of the correspondingly-numbered caveman rule.

### Rule 1: Sentence Combination (inverts Atomicity)

Combine related atomic thoughts into compound and complex sentences.

**Formal Definition**: A well-formed sentence may join multiple facts, actions, or logical steps using connectives and subordinate clauses, provided the relationships are clear.

```
❌ "Database needs index. Query runs faster."
✅ "The database needs an index, which will make the query run faster."
```

**Rationale**: Connectives express the relationships between facts that caveman discarded. Restoring them aids comprehension.

---

### Rule 2: Natural Sentence Length (inverts Word Count Limit)

Sentences SHOULD be of natural length — typically 10-25 words — favouring clarity and rhythm.

**Constraints**:
- Avoid run-on sentences that bury the logical chain.
- Vary length for cadence; do not pad merely to inflate word count.

```
✅ "We need fast queries."
✅ "Because an array scan is too slow, a hash map — which offers O(1) lookup — is the better choice."
```

---

### Rule 3: Connective Restoration (inverts Connective Elimination)

RESTORE logical connectives to make reasoning explicit and smooth.

**Encouraged connectives**:
- Causal: because, since, as a result, therefore
- Contrastive: however, although, despite, but
- Sequential: then, consequently, subsequently
- Purpose: in order to, so that

```
❌ "Query too slow. Use index."
✅ "Because the query is too slow, we should add an index."
```

**Constraint**: Add connectives only to express relationships the source already implies through ordering. Do not assert a causal link the source did not.

---

### Rule 4: Voice and Tense Flexibility (inverts Active/Present-only)

Use whichever voice and tense reads most naturally; passive voice and full temporal markers are now permitted where they aid flow.

```
✅ "The value is calculated by the function."   (passive acceptable)
✅ "We will need to check the constraints."      (future tense restored)
```

**Constraint**: Do not change *what happened* — only *how it is phrased*.

---

### Rule 5: Preserve Specifics (UNCHANGED from caveman)

Keep all specific numbers and quantities exactly. Never vaguen, round, or embellish them.

```
✅ "three variables" — not "several variables", and not "roughly three variables"
✅ "50 million daily requests" stays "50 million daily requests"
```

**Rationale**: Numbers carry information. This rule is identical in both directions — fidelity flows both ways.

---

### Rule 6: Restore Descriptive Flow, Not Intensifiers (inverts Intensifier Removal)

Restore natural descriptive language and connective adverbs, but do NOT smuggle in intensifiers that overstate the source.

```
✅ "an important constraint" — keep
✅ "notably, the lookup is fast" — signposting is fine
❌ "an extremely important, absolutely critical constraint"  (overstatement not in source)
```

---

### Rule 7: Article Restoration (inverts Article Omission)

Restore articles (`a`, `an`, `the`) for natural phrasing.

```
❌ "Database needs index"
✅ "The database needs an index."
```

---

### Rule 8: Pronoun Comfort (inverts cautious Pronoun Handling)

Use pronouns freely for flow where the referent is clear; introduce explicit nouns when starting a new thread of reference.

```
✅ "The function returns a value, which we then store in a variable and use later."
```

**Constraint**: If the source disambiguated a referent, preserve that disambiguation.

---

### Rule 9: Logical Completeness (UNCHANGED from caveman)

Every inference step remains explicit. Restoring prose must not *hide* a reasoning step behind smooth phrasing, nor *invent* a step to make the prose flow.

**Test**: The fact set and the reasoning chain are identical to the source — only the wording differs.

---

## Rhetorical Framing (the permitted "additions")

Beyond grammar, Reverse Caveman MAY add tasteful rhetorical packaging:

- **Topic sentences** that introduce what follows.
- **Signposting**: "First…", "Notably…", "In short…".
- **Mild hedging** where the source was already tentative.
- **Transitions** between paragraphs.

These add *structure*, never *content*. None of them may assert a new fact, example, or justification.

---

## Scope: What Stays Verbatim

The mode expands natural-language prose only. The following are reproduced byte-for-byte and never "expanded":

- **Code blocks, file paths, shell commands, function/variable names, error messages.**
- **Quoted or literal strings**, log lines, and user-provided text echoed back.
- **Numbers, versions, IDs, and flags** (also guaranteed by Rule 5).

Markdown lists and headings MAY be dissolved into flowing paragraphs when prose reads better — structure is stylistic, not protected.

---

## Edge Cases

### Conditionals

Restore explicit conditional framing dropped by caveman.

```
❌ "Value greater than ten. Return error."
✅ "If the value is greater than ten, return an error."
```

### Lists and Enumerations

A caveman bullet list may be re-expressed as prose, provided every item survives.

```
caveman:  "Install: React, Node, PostgreSQL."
✅ "Install the three dependencies — React, Node, and PostgreSQL."
```

### Technical Terminology

Preserve precise technical terms exactly; do not "explain them away" or substitute looser language.

```
✅ "binary search" stays "binary search" (do not expand to "a fast searching method")
```

---

## Validation Algorithm

To verify Reverse Caveman correctness:

1. **Extract facts** from the source (terse) text.
2. **Extract facts** from the expanded text.
3. **Compare sets**: they MUST be identical — no facts added, none lost, none altered.
4. **Check logical flow**: the reasoning chain matches the source exactly.
5. **Check readability**: the result reads as natural, fully-grammatical prose.

**Acceptance criteria**:
- Fact preservation: Complete (0 facts added, 0 lost, 0 altered).
- Logical completeness: Complete.
- Readability: Full grammar restored; flows naturally.
- Expansion ratio: **No target.** Length follows from content. The win is *stylistic completeness*, not bulk.

The inverse of caveman's "≥30% reduction" is not "≥30% inflation" — it is "**0% change in information**".

---

## Anti-Patterns

### Anti-Pattern 1 (CARDINAL SIN): Content Smuggling

This is the exact mirror of caveman's worst sin (Information Addition). Padding for length must never introduce unsupported claims.

```
❌ Source:    "Use hash map."
❌ Expanded:  "We should use a hash map, because it is the fastest and most
              memory-efficient data structure available."
              (invented "fastest", "most memory-efficient")

✅ Expanded:  "We should use a hash map."
```

**Problem**: Verbosity became a vehicle for facts not in the source. Faithfulness is forfeited.

---

### Anti-Pattern 2: Empty Inflation

```
❌ "It is worth noting that, in a very real sense, the database, at the end of
   the day, needs an index."
✅ "The database needs an index."
```

**Problem**: Filler words add tokens without adding clarity. Restore grammar, not waffle.

---

### Anti-Pattern 3: Information Loss via Smoothing

```
❌ Source:    "Check stack trace. Find error location. Add null check."
❌ Expanded:  "Investigate the error and add a guard."   (dropped two steps)
✅ Expanded:  "Check the stack trace to find the error location, then add a
              null check."
```

**Problem**: Smooth prose hid two of the three reasoning steps. Every step must survive.

---

## Examples by Category

### Algorithm Explanation

**Caveman (49 tokens)**:
```
Binary search divides search space in half. Compare target to middle element.
Match found. Return position. Target less than middle. Search left half.
Target greater than middle. Search right half.
```

**Reverse Caveman**:
```
Binary search works by repeatedly dividing the search space in half. First,
compare the target value to the middle element. If they match, return the
position. If the target is less than the middle, search the left half;
if it is greater, search the right half.
```

**Facts changed**: 0.

---

### Debugging Steps

**Caveman (54 tokens)**:
```
Debugging null pointer exception. Check stack trace. Find error location.
Examine code at error line. Identify null variable. Variable needs value
check. Add null check before dereference. Prevents error next time.
```

**Reverse Caveman**:
```
When debugging the null pointer exception, start by checking the stack trace
to identify where the error occurred. Then examine the code at that line to
see which variable is null. Adding a null check before the dereference will
prevent the error from happening again.
```

**Facts changed**: 0.
