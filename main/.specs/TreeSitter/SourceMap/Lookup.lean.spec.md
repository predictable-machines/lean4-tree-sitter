---
predictable: spec
---
## Specification Details
- **ID:** SPEC-001
- **Name:** TreeSitter/SourceMap/Lookup.lean

### Description
`Lookup.lean` — Lookup. 1 requirement: 1 violated.

### Notation

A requirement is a condition an operation needs in order not to fail in the way its own row names — an operation with several failures carries a row for each, and meeting one says nothing about the others. Some a caller supplies, others the operation establishes and checks itself. Nobody has checked the callers.

`implemented` — the operation exists in the code; every machine-written row carries it.

Tags: `[implemented, violated]` — the analysis found a case where the condition fails. Ids in the machine-managed sections below are assigned per run and are not stable references; cite the requirement's sentence.

### Analysis

#### SourceMap.traceError <!-- predictable:group -->

##### ANL-0001 [implemented, violated]
The index must be within the bounds of what it indexes.

<!-- predictable:analysis -->

<!-- predictable:subject=SourceMap.traceError -->

<!-- predictable:vc=il1.bounds -->

- **Code locations:** [code location](../../../.predictable-code/specs/locations/SPEC-001/ANL-0001.md)
