import TreeSitter.Types.GrammarSpec

namespace TreeSitter.Grammars

inductive GoNode where
  | function_declaration
  | method_declaration
  | type_spec
  | identifier
  | type_identifier
  | field_identifier
  deriving DecidableEq, Repr

instance : GrammarSpec GoNode where
  toDeclarationType
    | .function_declaration => some .function_
    | .method_declaration   => some .method_
    | .type_spec            => some .class_
    | .identifier           => none
    | .type_identifier      => none
    | .field_identifier     => none

  declarationNodes := [
    .function_declaration, .method_declaration, .type_spec
  ]

  nameNodes := [.identifier, .type_identifier, .field_identifier]

  queryString :=
    "(function_declaration name: (identifier) @name) @decl " ++
    "(method_declaration name: (field_identifier) @name) @decl " ++
    "(type_spec name: (type_identifier) @name) @decl"

  decl_nodes_total := by decide

end TreeSitter.Grammars
