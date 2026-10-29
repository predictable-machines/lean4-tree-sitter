---
predictable: overview
---
## Project overview

`main` is made of 1 area — TreeSitter — plus the project root, described area by area below. Written by the run of 2026-10-29T16:18:18+00:00[UTC].

`main` — “Lean 4 bindings for [tree-sitter](https://tree-sitter.github.io/tree-sitter/) — typed grammar schemas, declaration extraction, source maps, and verified properties.” 33 modules. 1 carries an inferred requirement, 1 requirement: 1 violated.

Needs attention: 1 violated requirement, in `Lookup.lean`. The analysis produced 1 obligation in all: 1 not known to be reached by any caller. The requirements and the observed behaviours are on the specification pages themselves, and Needs attention below lists one finding per class of defect, so a class with several findings gets one row and the rest are on the pages below.

`obligation` — one thing this run had to settle about one operation, most often that a particular failure cannot be reached. The 85 above are counted in these, and an obligation is not a finding: one the run could not settle reaches a page only when it can be stated as something a caller could act on.
`class of defect` — the family a row stands for, not one occurrence. A class can hold several distinct checks, so one row can stand for several findings. The module list further down gives each file's own counts.

### How these numbers reconcile

The rest name a throw and the condition that reaches it, and no caller this analysis can see is known to meet that condition — so they are counted here and are on no page rather than stated as something a caller must do; they are in the run's machine-readable results (`.predictable-code/verification/.analysis-results.json`).

1 of 33 modules produced an inferred requirement. The other 32 produced none — that is not evidence they are correct. Here, a module is a translated source file with at least one declaration; test files are not counted. This analysis looked at 129 functions: 1 carry an obligation it could not discharge, 128 came back clean,. All 1 of those reach a page. Every one of the 128 had no recorded obligation, so nothing was established about any of them. Here `clean` means this analysis refuted nothing, never that nothing is wrong. No requirement was proved in this run: `verified` means the operation performs the check in its own code, read from that code, and nothing here was discharged as a theorem.

### project root

0 of 1 modules carry an inferred requirement.

### `TreeSitter`

Its modules are grouped in 6 parts: `Grammars` (10), `FFI` (7), `Proofs` (4), `SourceMap` (4), `Types` (4) and `Extract` (2), plus 1 directly in `TreeSitter`.

Modules: Extract · Index · Language · Node and 28 more

1 of 32 modules carries an inferred requirement, 1 requirement: 1 violated. Not every row below repeats its requirement as a count, so the tallies there add up to fewer than this.

- `Lookup.lean` — 1 requirement: 1 violated.

A requirement is a condition an operation needs in order not to fail in the way its own row names — an operation with several failures carries a row for each, and meeting one says nothing about the others. Some a caller supplies, others the operation establishes and checks itself. Nobody has checked the callers.

**violated** — the analysis found a case where the condition fails.

