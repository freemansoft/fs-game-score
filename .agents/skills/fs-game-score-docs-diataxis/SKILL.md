---
name: fs-game-score-docs-diataxis
description: >
  Classify, audit, and author files in docs/ against the Diátaxis framework
  (tutorial / how-to / reference / explanation). Use when adding, restructuring,
  or reviewing a docs/*.md file — keeps each doc to one quadrant. Excludes
  design, spec, plan, and archive documents.
---

# FS Score Card — docs/ Diátaxis standard

Every prose doc under [`docs/`](../../../docs) belongs to **exactly one** [Diátaxis](https://diataxis.fr) quadrant. This skill classifies existing docs, flags content that mixes quadrants, and authors new docs in the right place. Files stay **flat in `docs/`** — the quadrant is declared in front matter, not by folder.

**Related skills:** `fs-game-score-flutter-patterns` (what the docs describe), `fs-game-score-release-engineer` (CHANGELOG/release notes — not in scope here).

---

## Scope — what this skill touches

**In scope:** user- and contributor-facing prose in `docs/*.md` that explains, teaches, references, or instructs.

**Out of scope — never restructure or tag these:**

| Excluded                                                                                               | Why                                                  |
| ------------------------------------------------------------------------------------------------------ | ---------------------------------------------------- |
| `docs/*-Design.md` (e.g. `Live-Score-Sharing-Design.md`)                                               | Design / decision log — a record, not Diátaxis prose |
| Anything under `specs/`, `plans/`, `archive/`, `adr/`, `rfc/`                                          | Planning artifacts, superseded content               |
| `CHANGELOG.md`, `AGENTS.md`, `CLAUDE.md`, `README.md`                                                  | Project meta / release records                       |
| Files whose title or front matter reads "design", "spec", "plan", "proposal", "decision", "RFC", "ADR" | Same reason — record, not documentation              |

When asked to "Diátaxis the docs," **skip excluded files silently** and list them under a "Skipped (out of scope)" heading so the exclusion is visible.

---

## The four quadrants

Classify by two axes: **action vs. cognition** and **acquisition (study) vs. application (work)**.

| Quadrant        | Serves        | User is              | Answers                 | Voice                               |
| --------------- | ------------- | -------------------- | ----------------------- | ----------------------------------- |
| **Tutorial**    | Learning      | studying + doing     | "teach me by doing"     | "we will…", one guaranteed path     |
| **How-to**      | A task        | working + doing      | "how do I accomplish X" | "to do X, do Y", assumes competence |
| **Reference**   | Looking up    | working + cognition  | "what exactly is X"     | dry, factual, scannable tables      |
| **Explanation** | Understanding | studying + cognition | "why is it like this"   | discursive, background, trade-offs  |

### Decision tree

1. Is it about **doing** an activity, or about **knowledge**?
2. **Doing →** does it serve _learning_ (Tutorial) or _a goal the reader already has_ (How-to)?
3. **Knowledge →** does it _describe the machinery_ (Reference) or _illuminate why_ (Explanation)?

---

## Front-matter tag

Every in-scope doc starts with:

```markdown
---
diataxis: reference # tutorial | how-to | reference | explanation
---

# Title
```

If a doc has no front matter yet, add the block above the H1. The tag is the contract the audit checks content against.

---

## Auditing an existing doc

For each in-scope file:

1. **Classify** it with the decision tree; record the intended quadrant.
2. **Check purity** against the anti-mixing rules below. A doc "mixes" when a section does a _different_ quadrant's job.
3. **Report**, don't silently rewrite — list each violation as `file:heading — <quadrant A> content inside a <quadrant B> doc → move/link`.
4. Only after the user confirms (or when they asked you to author/restructure) do you split or move content.

### Anti-mixing rules

- **How-to must not teach concepts.** Move the "why" to an Explanation and cross-link. (`How-To-Edit-Scores.md` is the task steps; `Game-Modes.md` is the reference it links to.)
- **Reference must not explain or instruct.** Keep it to facts/tables. (`Semantics-Labels.md` and `State-Reference.md` are clean Reference — use them as the model.)
- **Explanation must not be a step list.** Prose and trade-offs, not numbered procedures. (`State-Management.md` explains; the Riverpod procedure lives in `How-To-Riverpod.md`.)
- **Tutorial must offer one path.** No "optionally you could also…"; strip choices that break the guaranteed outcome.
- **Reference lives in Reference, even in a how-to.** If a how-to needs a table of keys, link to the Reference doc rather than duplicating it.

---

## Authoring or restructuring

- **New doc:** pick the quadrant _first_, add the `diataxis:` tag, then write in that quadrant's voice. If the request spans two quadrants, create two docs and cross-link — do not blend.
- **Splitting a mixed doc:** keep the original filename for its dominant quadrant; extract the off-quadrant sections into a new sibling doc; replace the extracted text with a one-line cross-link (`See [Explanation](Foo.md) for why…`). Preserve existing inbound links — grep the repo for the old filename/anchors before renaming.
- **Cross-links over duplication:** quadrants reference each other; they never repeat each other's content.
- Match repo doc style: H1 title, GitHub-flavored Markdown, relative links, tables for reference data (see existing docs).

---

## Current docs/ baseline

Current doc set after the 2026-07-07 restructure. Each doc is one quadrant; verify before acting — content drifts:

| File                           | Quadrant       | Notes                                                                     |
| ------------------------------ | -------------- | ------------------------------------------------------------------------- |
| `Semantics-Labels.md`          | reference      | widget keys / semantics labels                                            |
| `Help-And-Disclaimers.md`      | reference      | legal / trademark facts                                                   |
| `Game-Modes.md`                | reference      | per-mode scoring rules + internal models                                  |
| `State-Reference.md`           | reference      | domain model, repositories, prefs keys, key files                         |
| `Game-Sync.md`                 | reference      | sync providers, wire protocol, handshake                                  |
| `How-To-Edit-Scores.md`        | how-to         | editing names/scores per mode (extracted from `Game-Modes.md`)            |
| `How-To-Riverpod.md`           | how-to         | Riverpod coding rules + test setup (extracted from `State-Management.md`) |
| `State-Management.md`          | explanation    | state/persistence concepts, provider architecture, startup + splash-race  |
| `Live-Sync-Architecture.md`    | explanation    | sync design intent (extracted from `Game-Sync.md`)                        |
| `Live-Score-Sharing-Design.md` | — **excluded** | design / decision log                                                     |

**Known residual compromises (deliberate, not yet split):**

- `State-Management.md` → **Provider Architecture** keeps two repository-vs-notifier comparison tables inline; they illuminate the distinction (explanation's job) rather than serving cold lookup, so they stay. Field inventory lives in `State-Reference.md`.
- `State-Management.md` → **Identified … Problems … Resolved** is a record (out-of-scope quadrant); left in place, candidate to move to `CHANGELOG.md` later.

When restructuring, keep these anchors in their current file — they are linked from AGENTS.md / README / skills / the design doc:
`State-Management.md#splash-entry-and-coalesced-persist-race`, `State-Management.md#live-score-sync-lan-v1`, `State-Management.md#provider-architecture`, `How-To-Riverpod.md#integration-and-widget-testing`, `Game-Sync.md#handshake-and-validation`, `Game-Sync.md#join-ui-behavior`.

---

## Checklist before finishing

- [ ] Every in-scope `docs/*.md` has a valid `diataxis:` tag.
- [ ] No in-scope doc mixes quadrants (or violations are reported for the user to approve).
- [ ] Extracted content is cross-linked, not duplicated.
- [ ] Excluded files were skipped and listed as such.
- [ ] Inbound links to any renamed/split file still resolve (grep first).
