import TreeSitter.Types.CodeLocation
import Lean.Data.Json

namespace TreeSitter

inductive DeclarationType where
  | class_
  | interface_
  | enum_
  | struct_
  | function_
  | method_
  | constructor_
  | field_
  | property_
  | constant_
  | typeAlias
  | module_
  | package_
  | annotation_
  deriving DecidableEq, Repr, BEq, Hashable, Inhabited, Lean.ToJson, Lean.FromJson

structure Declaration where
  name      : String
  declType  : DeclarationType
  source    : SourceRange
  children  : Array Declaration := #[]
  modifiers : Array String := #[]
  deriving Repr, Inhabited, Lean.ToJson, Lean.FromJson

end TreeSitter
