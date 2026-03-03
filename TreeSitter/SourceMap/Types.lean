import TreeSitter.Types.Index

namespace TreeSitter.SourceMap

open TreeSitter

structure LeanLocation where
  module : String
  line   : Nat
  column : Nat
  deriving Repr, BEq, Inhabited

structure SourceMapping where
  source   : SourceRange
  lean     : LeanLocation
  declName : String
  declType : DeclarationType
  deriving Repr, Inhabited

structure SourceMap where
  entries    : Array SourceMapping
  sourceFile : String
  leanModule : String
  deriving Repr, Inhabited

def SourceMap.empty (sourceFile leanModule : String) : SourceMap :=
  { entries := #[], sourceFile, leanModule }

def SourceMap.addEntry (sm : SourceMap) (entry : SourceMapping) : SourceMap :=
  { sm with entries := sm.entries.push entry }

/-- Build a SourceMap from extraction results, assigning sequential Lean line numbers. -/
def SourceMap.fromDeclarations
    (decls : Array Declaration)
    (sourceFile leanModule : String)
    : SourceMap :=
  let (entries, _) := decls.foldl (init := (#[], 1)) fun (acc, leanLine) decl =>
    let mapping : SourceMapping := {
      source := decl.source
      lean := { module := leanModule, line := leanLine, column := 0 }
      declName := decl.name
      declType := decl.declType
    }
    let childMappings := decl.children.foldl (init := (#[], leanLine + 1)) fun (cacc, cline) child =>
      let cm : SourceMapping := {
        source := child.source
        lean := { module := leanModule, line := cline, column := 0 }
        declName := child.name
        declType := child.declType
      }
      (cacc.push cm, cline + 1)
    (acc.push mapping ++ childMappings.1, childMappings.2 + 1)
  { entries, sourceFile, leanModule }

end TreeSitter.SourceMap
