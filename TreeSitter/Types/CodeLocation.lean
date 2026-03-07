import Lean.Data.Json

namespace TreeSitter

structure SourceRange where
  startLine   : Nat
  startColumn : Nat
  endLine     : Nat
  endColumn   : Nat
  deriving Repr, BEq, Inhabited, Lean.ToJson, Lean.FromJson

end TreeSitter
