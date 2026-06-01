---
name: calc
description: Perform arithmetic, unit conversion, base conversion, currency conversion, and date/time & timezone conversion using the local qalc CLI
---

The user wants to perform a calculation. Use the locally installed `qalc` CLI to compute results accurately rather than relying on your own arithmetic.

## Key rule: always use `-defaults` flag

The local qalc installation has RPN mode enabled in its config. Always pass `-defaults` to override it and use standard infix notation:

```
qalc -defaults "<expression>"
```

## Translating natural language to qalc expressions

### Arithmetic
| User says | qalc expression |
|---|---|
| what is 3 + 4 | `3 + 4` |
| 15% of 230 | `15% * 230` |
| square root of 144 | `sqrt(144)` |
| 2 to the power of 10 | `2^10` |
| factorial of 7 | `7!` |
| log base 2 of 1024 | `log(1024, 2)` |

### Unit conversion
Use `VALUE UNIT to TARGET_UNIT` syntax:
| User says | qalc expression |
|---|---|
| 100 km to miles | `100 km to miles` |
| 32 fahrenheit to celsius | `32 fahrenheit to celsius` |
| 1 kg in pounds | `1 kg to pounds` |
| 1 litre to gallons | `1 litre to gallons` |
| 100 mph to km/h | `100 mph to km/h` |

### Number base conversion
Prefix source values: `0b` = binary, `0x` = hex, `0o` = octal. Use `to hex`, `to binary`, `to octal`, `to decimal` as the target:
| User says | qalc expression |
|---|---|
| binary 1010 to hex | `0b1010 to hex` |
| 255 to hexadecimal | `255 to hex` |
| 0xFF to decimal | `0xFF` |
| octal 17 to binary | `0o17 to binary` |

### Currency conversion
| User says | qalc expression |
|---|---|
| 100 USD to EUR | `100 USD to EUR` |
| 50 GBP in ZAR | `50 GBP to ZAR` |

**Exchange-rate freshness.** qalc caches rates in `~/.local/share/qalculate/`
(`rates.json`) and does *not* fetch on every call — a plain conversion reads the
cache. Under `-defaults` it never auto-fetches (the update policy is "ask", which
can't prompt non-interactively), so refresh on a schedule using the cache file's
own mtime — no separate timestamp file needed. Before a currency conversion,
refresh only if the cache is older than 1 day (ECB publishes rates daily):

```bash
RATES="$HOME/.local/share/qalculate/rates.json"
if [ -z "$(find "$RATES" -mtime -1 2>/dev/null)" ]; then
  qalc -e -defaults -t "100 USD to EUR"   # -e updates rates, then computes
else
  qalc -defaults -t "100 USD to EUR"      # cache is fresh
fi
```

`-e` (`-exrates`) forces an update and needs network; if it fails (offline), the
last cached rates are still used — say so and note the rate date. Non-currency
calculations never need `-e`.

### Date, time & timezone conversion

qalc has no IANA timezone *lookup* of its own, but it honours the system `TZ`
environment variable plus the OS tz database — so `TZ` controls the **output**
zone and DST is applied automatically. This makes conversion deterministic; do
not do timezone arithmetic in your head.

Two rules that make it work:
- Add `-t` (terse) for clean output, and wrap the datetime in a date function
  (`addDays(d, 0)`, `timestamp(d)`, `stamptodate(n)`). A bare quoted date like
  `"2026-06-01T15:00:00"` is parsed as arithmetic (`T` = tesla), not a date.
- Source datetimes are ISO 8601: `YYYY-MM-DDThh:mm:ss`. A trailing offset
  (`Z`, `+00:00`, `-04:00`) makes it absolute; **no** offset means "wall clock
  in the `TZ`-local zone". `TZ` must be a valid IANA name (`Area/City`).

**Case A — source has an explicit offset (or is UTC) → target zone.** One call;
set `TZ` to the target and let the offset in the string anchor the source:
| User says | command | result |
|---|---|---|
| 14:30 UTC on 2026-06-01 in Berlin | `TZ="Europe/Berlin" qalc -defaults -t 'addDays("2026-06-01T14:30:00Z", 0)'` | `2026-06-01T16:30:00` |
| 15:00 +02:00 in New York | `TZ="America/New_York" qalc -defaults -t 'addDays("2026-06-01T15:00:00+02:00", 0)'` | `2026-06-01T09:00:00` |

**Case B — named source zone → named target zone (no offset known).** Bridge
through a UTC epoch so DST is resolved on **both** ends; never guess an offset.
Interpret the naive wall clock under the source `TZ` to get the epoch, then
render that epoch under the target `TZ`:
1. `TZ="America/New_York" qalc -defaults -t 'timestamp("2026-06-01T15:00:00")'` → `1780340400`
2. `TZ="Europe/London" qalc -defaults -t "stamptodate(1780340400)"` → `2026-06-01T20:00:00`

So "3pm New York on 2026-06-01 is what time in London?" → 20:00 (DST-aware: EDT
in June; the same in January would resolve EST automatically).

**Case C — current time in a zone.** `now` respects `TZ`:
| User says | command |
|---|---|
| what time is it in Tokyo | `TZ="Asia/Tokyo" qalc -defaults -t 'now'` |
| current UTC time | `TZ="UTC" qalc -defaults -t 'now'` |

Other date helpers (all need a date-function wrapper): `addDays(d, n)`,
`addMonths`, `addYears`, `timestamp(d)` (→ Unix epoch), `stamptodate(n)` (epoch
→ date), `weekday(d)`. Show both the command and the converted result, and name
the zones in plain language (e.g. "3pm EDT = 8pm BST").

## Multi-step calculations

Break into multiple qalc calls, using the result of each step in the next. Show each step clearly.

Example — "convert 212 fahrenheit to celsius, then tell me if that's above boiling point":
1. `qalc -defaults "212 fahrenheit to celsius"` → 100 °C
2. State that 100 °C equals water's boiling point.

## Output format

For each calculation, show:

```
`qalc -defaults "<expression>"`
→ <result from qalc>
```

Then give a plain-language interpretation of the result (especially for unit conversions and currency where context helps).

If qalc returns a warning about RPN syntax errors, you forgot the `-defaults` flag — re-run with it.

If qalc returns an error, try rephrasing the expression (e.g. spell out unit names, use `*` not `×`) before falling back to explaining the limitation.
