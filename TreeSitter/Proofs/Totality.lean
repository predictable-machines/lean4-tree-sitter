import TreeSitter.Types.GrammarSpec
import TreeSitter.Grammars.Index

namespace TreeSitter.Proofs

open TreeSitter
open TreeSitter.Grammars

-- Re-exported totality proofs: every declared node maps to Some DeclarationType.
-- These are enforced at the typeclass level by GrammarSpec.decl_nodes_total;
-- the theorems here collect them in named form for documentation and downstream use.

theorem java_decl_total :
    ∀ n ∈ GrammarSpec.declarationNodes (Node := JavaNode),
      (GrammarSpec.toDeclarationType n).isSome = true :=
  GrammarSpec.decl_nodes_total

theorem python_decl_total :
    ∀ n ∈ GrammarSpec.declarationNodes (Node := PythonNode),
      (GrammarSpec.toDeclarationType n).isSome = true :=
  GrammarSpec.decl_nodes_total

theorem kotlin_decl_total :
    ∀ n ∈ GrammarSpec.declarationNodes (Node := KotlinNode),
      (GrammarSpec.toDeclarationType n).isSome = true :=
  GrammarSpec.decl_nodes_total

-- Stronger form: each specific declaration node maps to a concrete DeclarationType

theorem java_class_maps : GrammarSpec.toDeclarationType JavaNode.class_declaration = some .class_ := rfl
theorem java_interface_maps : GrammarSpec.toDeclarationType JavaNode.interface_declaration = some .interface_ := rfl
theorem java_enum_maps : GrammarSpec.toDeclarationType JavaNode.enum_declaration = some .enum_ := rfl
theorem java_method_maps : GrammarSpec.toDeclarationType JavaNode.method_declaration = some .method_ := rfl
theorem java_constructor_maps : GrammarSpec.toDeclarationType JavaNode.constructor_declaration = some .constructor_ := rfl
theorem java_field_maps : GrammarSpec.toDeclarationType JavaNode.field_declaration = some .field_ := rfl
theorem java_record_maps : GrammarSpec.toDeclarationType JavaNode.record_declaration = some .class_ := rfl

theorem python_function_maps : GrammarSpec.toDeclarationType PythonNode.function_definition = some .function_ := rfl
theorem python_class_maps : GrammarSpec.toDeclarationType PythonNode.class_definition = some .class_ := rfl

theorem kotlin_class_maps : GrammarSpec.toDeclarationType KotlinNode.class_declaration = some .class_ := rfl
theorem kotlin_function_maps : GrammarSpec.toDeclarationType KotlinNode.function_declaration = some .function_ := rfl
theorem kotlin_property_maps : GrammarSpec.toDeclarationType KotlinNode.property_declaration = some .property_ := rfl
theorem kotlin_type_alias_maps : GrammarSpec.toDeclarationType KotlinNode.type_alias = some .typeAlias := rfl

-- Name nodes never map to declarations (they are structural, not semantic)

theorem java_identifier_not_decl : GrammarSpec.toDeclarationType JavaNode.identifier = none := rfl
theorem python_identifier_not_decl : GrammarSpec.toDeclarationType PythonNode.identifier = none := rfl
theorem kotlin_identifier_not_decl : GrammarSpec.toDeclarationType KotlinNode.identifier = none := rfl
theorem kotlin_simple_identifier_not_decl : GrammarSpec.toDeclarationType KotlinNode.simple_identifier = none := rfl

end TreeSitter.Proofs
