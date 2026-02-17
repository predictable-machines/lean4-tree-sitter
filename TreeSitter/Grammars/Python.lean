import PredictableTreeSitter.Types.GrammarSpec

namespace PredictableTreeSitter.Grammars

inductive PythonNode where
  | function_definition
  | class_definition
  | decorated_definition
  | assignment
  | identifier
  deriving DecidableEq, Repr

instance : GrammarSpec PythonNode where
  toDeclarationType
    | .function_definition  => some .function_
    | .class_definition     => some .class_
    | .decorated_definition => some .function_
    | .assignment           => some .constant_
    | .identifier           => none

  declarationNodes := [
    .function_definition, .class_definition,
    .decorated_definition, .assignment
  ]

  nameNodes := [.identifier]

  -- queryString targets declarations with a direct `name` field.
  -- assignment is omitted because module-level assignments lack a `name`
  -- field; their names are resolved by the extraction engine's fallback
  -- strategy instead.
  queryString :=
    "(function_definition name: (identifier) @name) @decl " ++
    "(class_definition name: (identifier) @name) @decl " ++
    "(decorated_definition) @decl"

  decl_nodes_total := by decide

end PredictableTreeSitter.Grammars
