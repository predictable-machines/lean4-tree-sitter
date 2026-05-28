import TreeSitter.Types.GrammarSpec

namespace TreeSitter.Grammars

inductive TypeScriptNode where
  | class_declaration
  | abstract_class_declaration
  | interface_declaration
  | enum_declaration
  | type_alias_declaration
  | function_declaration
  | method_definition
  | public_field_definition
  | function_signature
  | abstract_method_signature
  | module
  | identifier
  | type_identifier
  | property_identifier
  deriving DecidableEq, Repr

instance : GrammarSpec TypeScriptNode where
  toDeclarationType
    | .class_declaration          => some .class_
    | .abstract_class_declaration => some .class_
    | .interface_declaration      => some .interface_
    | .enum_declaration           => some .enum_
    | .type_alias_declaration     => some .typeAlias
    | .function_declaration       => some .function_
    | .method_definition          => some .method_
    | .public_field_definition    => some .field_
    | .function_signature         => some .function_
    | .abstract_method_signature  => some .method_
    | .module                     => some .module_
    | .identifier                 => none
    | .type_identifier            => none
    | .property_identifier        => none

  declarationNodes := [
    .class_declaration, .abstract_class_declaration, .interface_declaration,
    .enum_declaration, .type_alias_declaration, .function_declaration,
    .method_definition, .public_field_definition, .function_signature,
    .abstract_method_signature, .module
  ]

  nameNodes := [.identifier, .type_identifier, .property_identifier]

  queryString :=
    "(class_declaration name: (type_identifier) @name) @decl " ++
    "(abstract_class_declaration name: (type_identifier) @name) @decl " ++
    "(interface_declaration name: (type_identifier) @name) @decl " ++
    "(enum_declaration name: (identifier) @name) @decl " ++
    "(type_alias_declaration name: (type_identifier) @name) @decl " ++
    "(function_declaration name: (identifier) @name) @decl"

  decl_nodes_total := by decide

end TreeSitter.Grammars
