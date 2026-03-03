import TreeSitter.SourceMap.Index

namespace TreeSitter.Proofs

open TreeSitter
open TreeSitter.SourceMap

-- Construction properties

theorem empty_entries (sf lm : String) :
    (SourceMap.empty sf lm).entries = #[] := rfl

theorem empty_sourceFile (sf lm : String) :
    (SourceMap.empty sf lm).sourceFile = sf := rfl

theorem empty_leanModule (sf lm : String) :
    (SourceMap.empty sf lm).leanModule = lm := rfl

theorem addEntry_sourceFile (sm : SourceMap) (e : SourceMapping) :
    (sm.addEntry e).sourceFile = sm.sourceFile := rfl

theorem addEntry_leanModule (sm : SourceMap) (e : SourceMapping) :
    (sm.addEntry e).leanModule = sm.leanModule := rfl

theorem addEntry_entries (sm : SourceMap) (e : SourceMapping) :
    (sm.addEntry e).entries = sm.entries.push e := rfl

-- Composition preserves metadata from the correct source maps

theorem compose_sourceFile (sm1 sm2 : SourceMap) :
    (sm1.compose sm2).sourceFile = sm1.sourceFile := rfl

theorem compose_leanModule (sm1 sm2 : SourceMap) :
    (sm1.compose sm2).leanModule = sm2.leanModule := rfl

-- Lookup on empty map always returns none

theorem lookupByLean_empty (loc : LeanLocation) (sf lm : String) :
    (SourceMap.empty sf lm).lookupByLean loc = none := rfl

theorem lookupBySource_empty (loc : SourceRange) (sf lm : String) :
    (SourceMap.empty sf lm).lookupBySource loc = none := rfl

theorem lookupByLeanLine_empty (line : Nat) (sf lm : String) :
    (SourceMap.empty sf lm).lookupByLeanLine line = none := rfl

theorem lookupByDeclName_empty (name : String) (sf lm : String) :
    (SourceMap.empty sf lm).lookupByDeclName name = none := rfl

-- traceError on empty map returns none

theorem traceError_empty (line : Nat) (sf lm : String) :
    (SourceMap.empty sf lm).traceError line = none := rfl

-- filterByType on empty map returns empty array

theorem filterByType_empty (dt : DeclarationType) (sf lm : String) :
    (SourceMap.empty sf lm).filterByType dt = #[] := rfl

-- traceError returns the exact source range when lookupByLeanLine succeeds

theorem traceError_exact (sm : SourceMap) (line : Nat) (m : SourceMapping)
    (h : sm.lookupByLeanLine line = some m) :
    sm.traceError line = some m.source := by
  simp [SourceMap.traceError, h]

-- fromDeclarations preserves metadata

theorem fromDeclarations_sourceFile (decls : Array Declaration) (sf lm : String) :
    (SourceMap.fromDeclarations decls sf lm).sourceFile = sf := rfl

theorem fromDeclarations_leanModule (decls : Array Declaration) (sf lm : String) :
    (SourceMap.fromDeclarations decls sf lm).leanModule = lm := rfl

-- fromDeclarations on empty input produces empty entries

theorem fromDeclarations_empty (sf lm : String) :
    (SourceMap.fromDeclarations #[] sf lm).entries = #[] := rfl

-- compose on empty maps produces empty entries

theorem compose_empty (sf1 lm1 sf2 lm2 : String) :
    (SourceMap.empty sf1 lm1).compose (SourceMap.empty sf2 lm2) =
    { entries := #[], sourceFile := sf1, leanModule := lm2 } := rfl

end TreeSitter.Proofs
