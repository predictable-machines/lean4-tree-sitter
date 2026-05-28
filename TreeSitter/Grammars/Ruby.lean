import TreeSitter.Types.GrammarSpec

namespace TreeSitter.Grammars

inductive RubyNode where
  | class
  | module
  | method
  | singleton_method
  | identifier
  | constant
  | scope_resolution
  deriving DecidableEq, Repr

instance : GrammarSpec RubyNode where
  toDeclarationType
    | .class            => some .class_
    | .module           => some .module_
    | .method           => some .method_
    | .singleton_method => some .method_
    | .identifier       => none
    | .constant         => none
    | .scope_resolution => none

  declarationNodes := [
    .class, .module, .method, .singleton_method
  ]

  nameNodes := [.identifier, .constant, .scope_resolution]

  queryString :=
    "(class name: (constant) @name) @decl " ++
    "(module name: (constant) @name) @decl " ++
    "(method name: (identifier) @name) @decl " ++
    "(singleton_method name: (identifier) @name) @decl"

  decl_nodes_total := by decide

end TreeSitter.Grammars
