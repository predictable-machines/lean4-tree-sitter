import TreeSitter.SourceMap.Lookup

namespace TreeSitter.SourceMap

/-- Compose two source maps to create a transitive mapping.
    sm1: source → intermediate, sm2: intermediate → lean
    Result: source → lean (skipping intermediate locations) -/
def SourceMap.compose (sm1 sm2 : SourceMap) : SourceMap :=
  let entries := sm2.entries.filterMap fun e2 =>
    match sm1.lookupByLeanLine e2.source.startLine with
    | some e1 => some {
        source := e1.source
        lean := e2.lean
        declName := e2.declName
        declType := e2.declType
      }
    | none => none
  { entries, sourceFile := sm1.sourceFile, leanModule := sm2.leanModule }

end TreeSitter.SourceMap
