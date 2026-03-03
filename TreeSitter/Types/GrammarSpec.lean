import TreeSitter.Types.Declaration

namespace TreeSitter

class GrammarSpec (Node : Type) where
  toDeclarationType : Node → Option DeclarationType
  declarationNodes  : List Node
  nameNodes         : List Node
  queryString       : String
  decl_nodes_total  : ∀ n, n ∈ declarationNodes → (toDeclarationType n).isSome = true

end TreeSitter
