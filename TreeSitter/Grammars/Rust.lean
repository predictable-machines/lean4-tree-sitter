import TreeSitter.Types.GrammarSpec

namespace TreeSitter.Grammars

inductive RustNode where
  | function_item
  | struct_item
  | enum_item
  | trait_item
  | impl_item
  | type_item
  | mod_item
  | const_item
  | static_item
  | identifier
  | type_identifier
  deriving DecidableEq, Repr

instance : GrammarSpec RustNode where
  toDeclarationType
    | .function_item   => some .function_
    | .struct_item     => some .struct_
    | .enum_item       => some .enum_
    | .trait_item      => some .interface_
    | .impl_item       => some .class_
    | .type_item       => some .typeAlias
    | .mod_item        => some .module_
    | .const_item      => some .constant_
    | .static_item     => some .constant_
    | .identifier      => none
    | .type_identifier => none

  declarationNodes := [
    .function_item, .struct_item, .enum_item, .trait_item,
    .impl_item, .type_item, .mod_item, .const_item, .static_item
  ]

  nameNodes := [.identifier, .type_identifier]

  queryString :=
    "(function_item name: (identifier) @name) @decl " ++
    "(struct_item name: (type_identifier) @name) @decl " ++
    "(enum_item name: (type_identifier) @name) @decl " ++
    "(trait_item name: (type_identifier) @name) @decl " ++
    "(impl_item type: (type_identifier) @name) @decl " ++
    "(type_item name: (type_identifier) @name) @decl " ++
    "(mod_item name: (identifier) @name) @decl " ++
    "(const_item name: (identifier) @name) @decl " ++
    "(static_item name: (identifier) @name) @decl"

  decl_nodes_total := by decide

end TreeSitter.Grammars
