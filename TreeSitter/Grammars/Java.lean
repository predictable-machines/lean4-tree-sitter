import PredictableTreeSitter.Types.GrammarSpec

namespace PredictableTreeSitter.Grammars

inductive JavaNode where
  | class_declaration
  | interface_declaration
  | enum_declaration
  | annotation_type_declaration
  | method_declaration
  | constructor_declaration
  | field_declaration
  | constant_declaration
  | record_declaration
  | identifier
  deriving DecidableEq, Repr

instance : GrammarSpec JavaNode where
  toDeclarationType
    | .class_declaration           => some .class_
    | .interface_declaration       => some .interface_
    | .enum_declaration            => some .enum_
    | .annotation_type_declaration => some .annotation_
    | .method_declaration          => some .method_
    | .constructor_declaration     => some .constructor_
    | .field_declaration           => some .field_
    | .constant_declaration        => some .constant_
    | .record_declaration          => some .class_
    | .identifier                  => none

  declarationNodes := [
    .class_declaration, .interface_declaration, .enum_declaration,
    .annotation_type_declaration, .method_declaration, .constructor_declaration,
    .field_declaration, .constant_declaration, .record_declaration
  ]

  nameNodes := [.identifier]

  -- queryString covers top-level named declarations that have a `name` field.
  -- field_declaration, constant_declaration, annotation_type_declaration, and
  -- record_declaration are omitted because they either lack a direct `name`
  -- field in the tree-sitter grammar or are extracted as nested children of
  -- the matched class/interface declarations instead.
  queryString :=
    "(class_declaration name: (identifier) @name) @decl " ++
    "(interface_declaration name: (identifier) @name) @decl " ++
    "(enum_declaration name: (identifier) @name) @decl " ++
    "(method_declaration name: (identifier) @name) @decl " ++
    "(constructor_declaration name: (identifier) @name) @decl"

  decl_nodes_total := by decide

end PredictableTreeSitter.Grammars
