namespace TreeSitter

structure SourceRange where
  startLine   : Nat
  startColumn : Nat
  endLine     : Nat
  endColumn   : Nat
  deriving Repr, BEq, Inhabited

end TreeSitter
