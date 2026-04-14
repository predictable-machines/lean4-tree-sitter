import TreeSitter.Types.GrammarSpec

namespace TreeSitter.Grammars

inductive JavaScriptNode where
  | class_declaration
  | function_declaration
  | generator_function_declaration
  | method_definition
  | field_definition
  | identifier
  | property_identifier
  deriving DecidableEq, Repr

instance : GrammarSpec JavaScriptNode where
  toDeclarationType
    | .class_declaration              => some .class_
    | .function_declaration           => some .function_
    | .generator_function_declaration => some .function_
    | .method_definition              => some .method_
    | .field_definition               => some .field_
    | .identifier                     => none
    | .property_identifier            => none

  declarationNodes := [
    .class_declaration, .function_declaration,
    .generator_function_declaration, .method_definition,
    .field_definition
  ]

  nameNodes := [.identifier, .property_identifier]

  queryString :=
    "(class_declaration name: (identifier) @name) @decl " ++
    "(function_declaration name: (identifier) @name) @decl " ++
    "(generator_function_declaration name: (identifier) @name) @decl"

  decl_nodes_total := by decide

end TreeSitter.Grammars
