# lean4-tree-sitter

Lean 4 bindings for [tree-sitter](https://tree-sitter.github.io/tree-sitter/) — typed grammar schemas, declaration extraction, source maps, and verified properties.

## Features

- **FFI Bindings**: Safe Lean 4 wrappers around tree-sitter C API (parser, tree, node, query)
- **Grammar Schemas**: Typed inductive types for Java, Python, and Kotlin nodes with a `GrammarSpec` typeclass and proof obligations
- **Extraction Engine**: Generic declaration extraction from source code producing typed `Declaration` arrays with source locations and nested children
- **Source Maps**: Bidirectional mapping between host-language source locations and generated Lean 4 code, with lookup, error tracing, and transitive composition
- **Verified Properties**: Kernel-checked proofs of mapping totality, cross-language consistency, and source map correctness

## Requirements

- [Lean 4](https://lean-lang.org/) (v4.28.0 or compatible)
- [elan](https://github.com/leanprover/elan) - Lean version manager (recommended)
- C compiler (gcc or clang) for tree-sitter FFI compilation

## Usage

Add to your `lakefile.lean`:

```lean
require «tree-sitter» from git
  "https://github.com/predictable-machines/lean4-tree-sitter" @ "v0.1.0"
```

Then import in your Lean code:

```lean
import TreeSitter

open TreeSitter
open TreeSitter.FFI
open TreeSitter.Extract

-- Parse Java source code
def example : IO Unit := do
  let parser ← TSParser.new
  let lang ← treeSitterJava
  let _ ← parser.setLanguage lang
  let tree ← parser.parseString "public class Hello { }"
  let root ← tree.rootNode
  let rootType ← root.type
  IO.println s!"Root node type: {rootType}"

-- Extract declarations from source code
def extractExample : IO Unit := do
  let decls ← extractJava "public class UserService { public void run() {} }"
  for d in decls do
    IO.println s!"{d.name} ({repr d.declType}) at line {d.source.startLine}"
```

## Build

```bash
make build           # Build the library (auto-vendors grammars if needed)
make test            # Build and run tests
make vendor-grammars # Re-vendor tree-sitter grammar sources
make clean           # Clean build artifacts and vendored grammars
```

## Module Structure

| Module | Purpose |
|--------|---------|
| `TreeSitter.FFI` | Safe Lean 4 wrappers around tree-sitter C API |
| `TreeSitter.Types` | Declaration, SourceRange, GrammarSpec typeclass |
| `TreeSitter.Grammars` | Java, Python, Kotlin grammar specifications |
| `TreeSitter.Extract` | Generic declaration extraction engine |
| `TreeSitter.SourceMap` | Bidirectional source location mapping |
| `TreeSitter.Proofs` | Totality, consistency, and source map proofs |

## Supported Languages

| Language | Parser | Scanner | Declarations |
|----------|--------|---------|-------------|
| Java | tree-sitter-java | No | class, interface, enum, method, constructor, field, annotation |
| Python | tree-sitter-python | Yes | class, function |
| Kotlin | tree-sitter-kotlin (fwcd) | Yes | class, interface, function, property, type alias, annotation, object |

## License

MIT
