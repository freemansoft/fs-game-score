#!/usr/bin/env python3
"""Fail if any accessibility (screen-reader) label is a hardcoded string literal.

`semanticLabel:`, `semanticsLabel:`, and `Semantics(label:)` are read aloud by
screen readers, so they are user-facing text and must be localized. This guard
flags any of those sinks whose value is a bare `'...'` / `"..."` literal instead
of an `l10n` / `AppLocalizations` call.

Canonical rule: .agents/skills/fs-game-score-flutter-patterns/SKILL.md (Localization).

Usage:  python3 tool/check_semantic_l10n.py        # scans lib/
Exit 0 = clean, 1 = violations found.
"""
from __future__ import annotations

import pathlib
import re
import sys

LIB = pathlib.Path(__file__).resolve().parent.parent / "lib"

# The a11y label sinks we police. `label:` is only a sink inside a Semantics(...).
PROP_RE = re.compile(r"\b(semanticLabel|semanticsLabel)\s*:\s*(.*)$")
SEMANTICS_LABEL_RE = re.compile(r"\bSemantics\s*\([^)]*?\blabel\s*:\s*(.*)$", re.DOTALL)


def value_starts_hardcoded(value: str, lines: list[str], idx: int) -> bool:
    """True if the value token is a string literal.

    `value` is the remainder of the line after the `key:`. If it is empty (the
    argument wraps to the next line), peek at the next non-blank line.
    """
    value = value.strip()
    if not value:
        for peek in lines[idx + 1 :]:
            peek = peek.strip()
            if peek:
                value = peek
                break
    # Ignore interpolation-free localization calls and everything non-literal.
    return value.startswith(("'", '"'))


def scan(path: pathlib.Path) -> list[tuple[int, str]]:
    lines = path.read_text(encoding="utf-8").splitlines()
    hits: list[tuple[int, str]] = []
    in_semantics = 0  # lines remaining in a recently-opened Semantics(...) window
    for i, line in enumerate(lines):
        if "Semantics(" in line:
            in_semantics = 8  # covers multi-line Semantics constructors

        m = PROP_RE.search(line)
        if m and value_starts_hardcoded(m.group(2), lines, i):
            hits.append((i + 1, line.strip()))

        if in_semantics > 0:
            lm = re.search(r"\blabel\s*:\s*(.*)$", line)
            if lm and value_starts_hardcoded(lm.group(1), lines, i):
                hits.append((i + 1, line.strip()))
            in_semantics -= 1
    return hits


def main() -> int:
    violations: list[str] = []
    for dart in sorted(LIB.rglob("*.dart")):
        for lineno, text in scan(dart):
            rel = dart.relative_to(LIB.parent)
            violations.append(f"{rel}:{lineno}: {text}")

    if violations:
        sys.stderr.write(
            "Hardcoded accessibility labels found — these are read by screen "
            "readers and must be localized via AppLocalizations.\n"
            "See .agents/skills/fs-game-score-flutter-patterns/SKILL.md "
            "(Localization).\n\n"
        )
        sys.stderr.write("\n".join(violations) + "\n")
        return 1

    print("OK: all semantic labels are localized.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
