import PredictableTreeSitter.SourceMap.Types

namespace PredictableTreeSitter.SourceMap

open PredictableTreeSitter

def SourceMap.lookupByLean (sm : SourceMap) (loc : LeanLocation) : Option SourceMapping :=
  sm.entries.find? fun m => m.lean == loc

def SourceMap.lookupBySource (sm : SourceMap) (loc : SourceRange) : Option SourceMapping :=
  sm.entries.find? fun m => m.source == loc

def SourceMap.lookupByLeanLine (sm : SourceMap) (line : Nat) : Option SourceMapping :=
  sm.entries.find? fun m => m.lean.line == line

def SourceMap.lookupByDeclName (sm : SourceMap) (name : String) : Option SourceMapping :=
  sm.entries.find? fun m => m.declName == name

/-- Trace a Lean error line back to source.
    Returns the exact mapping if one exists, otherwise the nearest preceding entry. -/
def SourceMap.traceError (sm : SourceMap) (leanLine : Nat) : Option SourceRange :=
  match sm.lookupByLeanLine leanLine with
  | some mapping => some mapping.source
  | none =>
    let preceding := sm.entries.filter fun m => m.lean.line ≤ leanLine
    if preceding.size > 0 then
      some preceding[preceding.size - 1]!.source
    else
      none

/-- Get all entries for a given declaration type. -/
def SourceMap.filterByType (sm : SourceMap) (dt : DeclarationType) : Array SourceMapping :=
  sm.entries.filter fun m => m.declType == dt

end PredictableTreeSitter.SourceMap
