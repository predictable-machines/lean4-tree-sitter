import TreeSitter.Types.GrammarSpec

namespace TreeSitter.Grammars

inductive CSharpNode where
  | class_declaration
  | interface_declaration
  | struct_declaration
  | enum_declaration
  | record_declaration
  | method_declaration
  | constructor_declaration
  | property_declaration
  | field_declaration
  | namespace_declaration
  | delegate_declaration
  | identifier
  deriving DecidableEq, Repr

instance : GrammarSpec CSharpNode where
  toDeclarationType
    | .class_declaration       => some .class_
    | .interface_declaration   => some .interface_
    | .struct_declaration      => some .struct_
    | .enum_declaration        => some .enum_
    | .record_declaration      => some .class_
    | .method_declaration      => some .method_
    | .constructor_declaration => some .constructor_
    | .property_declaration    => some .property_
    | .field_declaration       => some .field_
    | .namespace_declaration   => some .module_
    | .delegate_declaration    => some .typeAlias
    | .identifier              => none

  declarationNodes := [
    .class_declaration, .interface_declaration, .struct_declaration,
    .enum_declaration, .record_declaration, .method_declaration,
    .constructor_declaration, .property_declaration, .field_declaration,
    .namespace_declaration, .delegate_declaration
  ]

  nameNodes := [.identifier]

  queryString :=
    "(class_declaration name: (identifier) @name) @decl " ++
    "(interface_declaration name: (identifier) @name) @decl " ++
    "(struct_declaration name: (identifier) @name) @decl " ++
    "(enum_declaration name: (identifier) @name) @decl " ++
    "(record_declaration name: (identifier) @name) @decl " ++
    "(method_declaration name: (identifier) @name) @decl " ++
    "(constructor_declaration name: (identifier) @name) @decl " ++
    "(namespace_declaration name: (identifier) @name) @decl " ++
    "(delegate_declaration name: (identifier) @name) @decl"

  decl_nodes_total := by decide

end TreeSitter.Grammars
