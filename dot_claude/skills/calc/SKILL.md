---
name: calc
description: Perform arithmetic, unit conversion, base conversion, and currency conversion using the local qalc CLI
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
