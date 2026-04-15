import TreeSitter.Types.Index
import TreeSitter.Grammars.Index

namespace Test.TS.GrammarSpec

open TreeSitter
open TreeSitter.Grammars

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
#check (GrammarSpec.decl_nodes_total (Node := TypeScriptNode))
#check (GrammarSpec.decl_nodes_total (Node := JavaScriptNode))
#check (GrammarSpec.decl_nodes_total (Node := GoNode))
#check (GrammarSpec.decl_nodes_total (Node := RustNode))
#check (GrammarSpec.decl_nodes_total (Node := CSharpNode))
#check (GrammarSpec.decl_nodes_total (Node := RubyNode))

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

example : GrammarSpec.toDeclarationType TypeScriptNode.class_declaration = some .class_ := rfl
example : GrammarSpec.toDeclarationType TypeScriptNode.abstract_class_declaration = some .class_ := rfl
example : GrammarSpec.toDeclarationType TypeScriptNode.interface_declaration = some .interface_ := rfl
example : GrammarSpec.toDeclarationType TypeScriptNode.enum_declaration = some .enum_ := rfl
example : GrammarSpec.toDeclarationType TypeScriptNode.type_alias_declaration = some .typeAlias := rfl
example : GrammarSpec.toDeclarationType TypeScriptNode.function_declaration = some .function_ := rfl
example : GrammarSpec.toDeclarationType TypeScriptNode.method_definition = some .method_ := rfl
example : GrammarSpec.toDeclarationType TypeScriptNode.identifier = none := rfl

example : GrammarSpec.toDeclarationType JavaScriptNode.class_declaration = some .class_ := rfl
example : GrammarSpec.toDeclarationType JavaScriptNode.function_declaration = some .function_ := rfl
example : GrammarSpec.toDeclarationType JavaScriptNode.generator_function_declaration = some .function_ := rfl
example : GrammarSpec.toDeclarationType JavaScriptNode.method_definition = some .method_ := rfl
example : GrammarSpec.toDeclarationType JavaScriptNode.identifier = none := rfl

example : GrammarSpec.toDeclarationType GoNode.function_declaration = some .function_ := rfl
example : GrammarSpec.toDeclarationType GoNode.method_declaration = some .method_ := rfl
example : GrammarSpec.toDeclarationType GoNode.type_spec = some .class_ := rfl
example : GrammarSpec.toDeclarationType GoNode.identifier = none := rfl

example : GrammarSpec.toDeclarationType RustNode.function_item = some .function_ := rfl
example : GrammarSpec.toDeclarationType RustNode.struct_item = some .struct_ := rfl
example : GrammarSpec.toDeclarationType RustNode.enum_item = some .enum_ := rfl
example : GrammarSpec.toDeclarationType RustNode.trait_item = some .interface_ := rfl
example : GrammarSpec.toDeclarationType RustNode.impl_item = some .class_ := rfl
example : GrammarSpec.toDeclarationType RustNode.identifier = none := rfl

example : GrammarSpec.toDeclarationType CSharpNode.class_declaration = some .class_ := rfl
example : GrammarSpec.toDeclarationType CSharpNode.interface_declaration = some .interface_ := rfl
example : GrammarSpec.toDeclarationType CSharpNode.struct_declaration = some .struct_ := rfl
example : GrammarSpec.toDeclarationType CSharpNode.enum_declaration = some .enum_ := rfl
example : GrammarSpec.toDeclarationType CSharpNode.method_declaration = some .method_ := rfl
example : GrammarSpec.toDeclarationType CSharpNode.identifier = none := rfl

example : GrammarSpec.toDeclarationType RubyNode.class = some .class_ := rfl
example : GrammarSpec.toDeclarationType RubyNode.module = some .module_ := rfl
example : GrammarSpec.toDeclarationType RubyNode.method = some .method_ := rfl
example : GrammarSpec.toDeclarationType RubyNode.singleton_method = some .method_ := rfl
example : GrammarSpec.toDeclarationType RubyNode.identifier = none := rfl

-- Cross-language consistency: classes map to the same DeclarationType
example : GrammarSpec.toDeclarationType JavaNode.class_declaration =
          GrammarSpec.toDeclarationType KotlinNode.class_declaration := rfl

example : GrammarSpec.toDeclarationType JavaNode.interface_declaration =
          GrammarSpec.toDeclarationType KotlinNode.interface_declaration := rfl

example : GrammarSpec.toDeclarationType JavaNode.class_declaration =
          GrammarSpec.toDeclarationType TypeScriptNode.class_declaration := rfl

example : GrammarSpec.toDeclarationType JavaNode.interface_declaration =
          GrammarSpec.toDeclarationType TypeScriptNode.interface_declaration := rfl

example : GrammarSpec.toDeclarationType JavaNode.class_declaration =
          GrammarSpec.toDeclarationType JavaScriptNode.class_declaration := rfl

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
  let tsDecls := GrammarSpec.declarationNodes (Node := TypeScriptNode)
  if javaDecls.length != 9 then
    throw (IO.userError s!"testDeclarationNodeCounts: FAIL - Java has {javaDecls.length} decl nodes, expected 9")
  if pythonDecls.length != 4 then
    throw (IO.userError s!"testDeclarationNodeCounts: FAIL - Python has {pythonDecls.length} decl nodes, expected 4")
  if kotlinDecls.length != 8 then
    throw (IO.userError s!"testDeclarationNodeCounts: FAIL - Kotlin has {kotlinDecls.length} decl nodes, expected 8")
  if tsDecls.length != 11 then
    throw (IO.userError s!"testDeclarationNodeCounts: FAIL - TypeScript has {tsDecls.length} decl nodes, expected 11")
  let jsDecls := GrammarSpec.declarationNodes (Node := JavaScriptNode)
  if jsDecls.length != 5 then
    throw (IO.userError s!"testDeclarationNodeCounts: FAIL - JavaScript has {jsDecls.length} decl nodes, expected 5")
  let goDecls := GrammarSpec.declarationNodes (Node := GoNode)
  if goDecls.length != 3 then
    throw (IO.userError s!"testDeclarationNodeCounts: FAIL - Go has {goDecls.length} decl nodes, expected 3")
  let rustDecls := GrammarSpec.declarationNodes (Node := RustNode)
  if rustDecls.length != 9 then
    throw (IO.userError s!"testDeclarationNodeCounts: FAIL - Rust has {rustDecls.length} decl nodes, expected 9")
  let csDecls := GrammarSpec.declarationNodes (Node := CSharpNode)
  if csDecls.length != 11 then
    throw (IO.userError s!"testDeclarationNodeCounts: FAIL - C# has {csDecls.length} decl nodes, expected 11")
  let rubyDecls := GrammarSpec.declarationNodes (Node := RubyNode)
  if rubyDecls.length != 4 then
    throw (IO.userError s!"testDeclarationNodeCounts: FAIL - Ruby has {rubyDecls.length} decl nodes, expected 4")
  IO.println s!"  testDeclarationNodeCounts: PASS (Java={javaDecls.length}, Python={pythonDecls.length}, Kotlin={kotlinDecls.length}, TypeScript={tsDecls.length}, JavaScript={jsDecls.length}, Go={goDecls.length}, Rust={rustDecls.length}, C#={csDecls.length}, Ruby={rubyDecls.length})"

def testNameNodeCounts : IO Unit := do
  let javaNames := GrammarSpec.nameNodes (Node := JavaNode)
  let pythonNames := GrammarSpec.nameNodes (Node := PythonNode)
  let kotlinNames := GrammarSpec.nameNodes (Node := KotlinNode)
  let tsNames := GrammarSpec.nameNodes (Node := TypeScriptNode)
  if javaNames.length != 1 then
    throw (IO.userError s!"testNameNodeCounts: FAIL - Java has {javaNames.length} name nodes, expected 1")
  if pythonNames.length != 1 then
    throw (IO.userError s!"testNameNodeCounts: FAIL - Python has {pythonNames.length} name nodes, expected 1")
  if kotlinNames.length != 2 then
    throw (IO.userError s!"testNameNodeCounts: FAIL - Kotlin has {kotlinNames.length} name nodes, expected 2")
  if tsNames.length != 3 then
    throw (IO.userError s!"testNameNodeCounts: FAIL - TypeScript has {tsNames.length} name nodes, expected 3")
  let jsNames := GrammarSpec.nameNodes (Node := JavaScriptNode)
  if jsNames.length != 2 then
    throw (IO.userError s!"testNameNodeCounts: FAIL - JavaScript has {jsNames.length} name nodes, expected 2")
  let goNames := GrammarSpec.nameNodes (Node := GoNode)
  if goNames.length != 3 then
    throw (IO.userError s!"testNameNodeCounts: FAIL - Go has {goNames.length} name nodes, expected 3")
  let rustNames := GrammarSpec.nameNodes (Node := RustNode)
  if rustNames.length != 2 then
    throw (IO.userError s!"testNameNodeCounts: FAIL - Rust has {rustNames.length} name nodes, expected 2")
  let csNames := GrammarSpec.nameNodes (Node := CSharpNode)
  if csNames.length != 1 then
    throw (IO.userError s!"testNameNodeCounts: FAIL - C# has {csNames.length} name nodes, expected 1")
  let rubyNames := GrammarSpec.nameNodes (Node := RubyNode)
  if rubyNames.length != 3 then
    throw (IO.userError s!"testNameNodeCounts: FAIL - Ruby has {rubyNames.length} name nodes, expected 3")
  IO.println s!"  testNameNodeCounts: PASS (Java={javaNames.length}, Python={pythonNames.length}, Kotlin={kotlinNames.length}, TypeScript={tsNames.length}, JavaScript={jsNames.length}, Go={goNames.length}, Rust={rustNames.length}, C#={csNames.length}, Ruby={rubyNames.length})"

def runAllTests : IO Unit := do
  IO.println "Running GrammarSpec tests..."
  IO.println ""
  testJavaQueryStringNonEmpty
  testDeclarationNodeCounts
  testNameNodeCounts
  IO.println ""
  IO.println "All GrammarSpec tests passed! (3 runtime + 52 compile-time)"

end Test.TS.GrammarSpec
