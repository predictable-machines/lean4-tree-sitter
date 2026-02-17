import PredictableTreeSitter.Types.GrammarSpec
import PredictableTreeSitter.Grammars.Index

namespace PredictableTreeSitter.Proofs

open PredictableTreeSitter
open PredictableTreeSitter.Grammars

-- Cross-language consistency: the same semantic concept maps to the same
-- DeclarationType across all three languages.

-- Classes
theorem java_kotlin_class_agree :
    GrammarSpec.toDeclarationType JavaNode.class_declaration =
    GrammarSpec.toDeclarationType KotlinNode.class_declaration := rfl

theorem java_python_class_agree :
    GrammarSpec.toDeclarationType JavaNode.class_declaration = some .class_ ∧
    GrammarSpec.toDeclarationType PythonNode.class_definition = some .class_ :=
  ⟨rfl, rfl⟩

-- Interfaces
theorem java_kotlin_interface_agree :
    GrammarSpec.toDeclarationType JavaNode.interface_declaration =
    GrammarSpec.toDeclarationType KotlinNode.interface_declaration := rfl

-- Functions/Methods
theorem java_method_python_function :
    GrammarSpec.toDeclarationType JavaNode.method_declaration = some .method_ ∧
    GrammarSpec.toDeclarationType PythonNode.function_definition = some .function_ :=
  ⟨rfl, rfl⟩

theorem java_kotlin_function_agree :
    GrammarSpec.toDeclarationType JavaNode.method_declaration = some .method_ ∧
    GrammarSpec.toDeclarationType KotlinNode.function_declaration = some .function_ :=
  ⟨rfl, rfl⟩

-- Kotlin object_declaration and companion_object both map to class_
-- (consistent with the Kotlin language semantics where objects are singletons)
theorem kotlin_objects_are_classes :
    GrammarSpec.toDeclarationType KotlinNode.object_declaration = some .class_ ∧
    GrammarSpec.toDeclarationType KotlinNode.companion_object = some .class_ :=
  ⟨rfl, rfl⟩

-- Java record_declaration maps to class_ (records are special classes)
theorem java_record_is_class :
    GrammarSpec.toDeclarationType JavaNode.record_declaration =
    GrammarSpec.toDeclarationType JavaNode.class_declaration := rfl

-- Python decorated_definition maps to function_ (same as function_definition)
theorem python_decorated_is_function :
    GrammarSpec.toDeclarationType PythonNode.decorated_definition =
    GrammarSpec.toDeclarationType PythonNode.function_definition := rfl

end PredictableTreeSitter.Proofs
