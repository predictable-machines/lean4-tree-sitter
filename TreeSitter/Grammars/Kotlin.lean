import PredictableTreeSitter.Types.GrammarSpec

namespace PredictableTreeSitter.Grammars

inductive KotlinNode where
  | class_declaration
  | object_declaration
  | interface_declaration
  | enum_class_body
  | function_declaration
  | property_declaration
  | type_alias
  | companion_object
  | identifier
  | simple_identifier
  deriving DecidableEq, Repr

instance : GrammarSpec KotlinNode where
  toDeclarationType
    | .class_declaration     => some .class_
    | .object_declaration    => some .class_
    | .interface_declaration => some .interface_
    | .enum_class_body       => some .enum_
    | .function_declaration  => some .function_
    | .property_declaration  => some .property_
    | .type_alias            => some .typeAlias
    | .companion_object      => some .class_
    | .identifier            => none
    | .simple_identifier     => none

  declarationNodes := [
    .class_declaration, .object_declaration, .interface_declaration,
    .enum_class_body, .function_declaration, .property_declaration,
    .type_alias, .companion_object
  ]

  nameNodes := [.identifier, .simple_identifier]

  -- queryString covers primary named declarations. interface_declaration,
  -- enum_class_body, property_declaration, type_alias, and companion_object
  -- are omitted because they use different name field patterns or are
  -- extracted as nested children of matched class/object declarations.
  queryString :=
    "(class_declaration (type_identifier) @name) @decl " ++
    "(object_declaration (type_identifier) @name) @decl " ++
    "(function_declaration (simple_identifier) @name) @decl"

  decl_nodes_total := by decide

end PredictableTreeSitter.Grammars
