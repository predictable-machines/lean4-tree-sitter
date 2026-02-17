import PredictableTreeSitter.Types.Index
import PredictableTreeSitter.Grammars.Index

namespace Test.TreeSitter.GrammarSpec

open PredictableTreeSitter
open PredictableTreeSitter.Grammars

private def strContains (haystack needle : String) : Bool :=
  needle.length ≤ haystack.length &&
    (List.range (haystack.length - needle.length + 1)).any fun i =>
      let sub := haystack.drop i |>.take needle.length
      sub == needle

-- Compile-time verification: every declaration node maps to Some
-- (These are proven in the GrammarSpec instances; repeating here confirms they hold)

#check (GrammarSpec.decl_nodes_total (Node := JavaNode))
#check (GrammarSpec.decl_nodes_total (Node := PythonNode))
#check (GrammarSpec.decl_nodes_total (Node := KotlinNode))

-- Compile-time: verify specific mappings

example : GrammarSpec.toDeclarationType JavaNode.class_declaration = some .class_ := rfl
example : GrammarSpec.toDeclarationType JavaNode.method_declaration = some .method_ := rfl
example : GrammarSpec.toDeclarationType JavaNode.interface_declaration = some .interface_ := rfl
example : GrammarSpec.toDeclarationType JavaNode.enum_declaration = some .enum_ := rfl
example : GrammarSpec.toDeclarationType JavaNode.identifier = none := rfl

example : GrammarSpec.toDeclarationType PythonNode.class_definition = some .class_ := rfl
example : GrammarSpec.toDeclarationType PythonNode.function_definition = some .function_ := rfl
example : GrammarSpec.toDeclarationType PythonNode.identifier = none := rfl

example : GrammarSpec.toDeclarationType KotlinNode.class_declaration = some .class_ := rfl
example : GrammarSpec.toDeclarationType KotlinNode.function_declaration = some .function_ := rfl
example : GrammarSpec.toDeclarationType KotlinNode.property_declaration = some .property_ := rfl
example : GrammarSpec.toDeclarationType KotlinNode.type_alias = some .typeAlias := rfl
example : GrammarSpec.toDeclarationType KotlinNode.identifier = none := rfl

-- Cross-language consistency: classes map to the same DeclarationType
example : GrammarSpec.toDeclarationType JavaNode.class_declaration =
          GrammarSpec.toDeclarationType KotlinNode.class_declaration := rfl

example : GrammarSpec.toDeclarationType JavaNode.interface_declaration =
          GrammarSpec.toDeclarationType KotlinNode.interface_declaration := rfl

-- Runtime tests for queryString and list properties
def testJavaQueryStringNonEmpty : IO Unit := do
  let qs := GrammarSpec.queryString (Node := JavaNode)
  if qs.length == 0 then
    throw (IO.userError "testJavaQueryStringNonEmpty: FAIL")
  if !strContains qs "class_declaration" then
    throw (IO.userError "testJavaQueryStringNonEmpty: FAIL - missing class_declaration")
  IO.println "  testJavaQueryStringNonEmpty: PASS"

def testDeclarationNodeCounts : IO Unit := do
  let javaDecls := GrammarSpec.declarationNodes (Node := JavaNode)
  let pythonDecls := GrammarSpec.declarationNodes (Node := PythonNode)
  let kotlinDecls := GrammarSpec.declarationNodes (Node := KotlinNode)
  if javaDecls.length != 9 then
    throw (IO.userError s!"testDeclarationNodeCounts: FAIL - Java has {javaDecls.length} decl nodes, expected 9")
  if pythonDecls.length != 4 then
    throw (IO.userError s!"testDeclarationNodeCounts: FAIL - Python has {pythonDecls.length} decl nodes, expected 4")
  if kotlinDecls.length != 8 then
    throw (IO.userError s!"testDeclarationNodeCounts: FAIL - Kotlin has {kotlinDecls.length} decl nodes, expected 8")
  IO.println s!"  testDeclarationNodeCounts: PASS (Java={javaDecls.length}, Python={pythonDecls.length}, Kotlin={kotlinDecls.length})"

def testNameNodeCounts : IO Unit := do
  let javaNames := GrammarSpec.nameNodes (Node := JavaNode)
  let pythonNames := GrammarSpec.nameNodes (Node := PythonNode)
  let kotlinNames := GrammarSpec.nameNodes (Node := KotlinNode)
  if javaNames.length != 1 then
    throw (IO.userError s!"testNameNodeCounts: FAIL - Java has {javaNames.length} name nodes, expected 1")
  if pythonNames.length != 1 then
    throw (IO.userError s!"testNameNodeCounts: FAIL - Python has {pythonNames.length} name nodes, expected 1")
  if kotlinNames.length != 2 then
    throw (IO.userError s!"testNameNodeCounts: FAIL - Kotlin has {kotlinNames.length} name nodes, expected 2")
  IO.println s!"  testNameNodeCounts: PASS (Java={javaNames.length}, Python={pythonNames.length}, Kotlin={kotlinNames.length})"

def runAllTests : IO Unit := do
  IO.println "Running GrammarSpec tests..."
  IO.println ""
  testJavaQueryStringNonEmpty
  testDeclarationNodeCounts
  testNameNodeCounts
  IO.println ""
  IO.println "All GrammarSpec tests passed! (3 runtime + 15 compile-time)"

end Test.TreeSitter.GrammarSpec
