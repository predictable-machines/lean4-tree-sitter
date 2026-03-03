import TreeSitter.FFI.Index

namespace Test.TS.FFI

open TreeSitter.FFI

private def strContains (haystack needle : String) : Bool :=
  needle.length ≤ haystack.length &&
    (List.range (haystack.length - needle.length + 1)).any fun i =>
      let sub := haystack.drop i |>.take needle.length
      sub == needle

private def javaSource : String :=
  "public class UserService {\n" ++
  "    private String name;\n" ++
  "\n" ++
  "    public UserService(String name) {\n" ++
  "        this.name = name;\n" ++
  "    }\n" ++
  "\n" ++
  "    public String getName() {\n" ++
  "        return name;\n" ++
  "    }\n" ++
  "}\n"

private def pythonSource : String :=
  "class Calculator:\n" ++
  "    def __init__(self, value):\n" ++
  "        self.value = value\n" ++
  "\n" ++
  "    def add(self, x):\n" ++
  "        return self.value + x\n" ++
  "\n" ++
  "def helper():\n" ++
  "    pass\n"

private def kotlinSource : String :=
  "class Greeter(val name: String) {\n" ++
  "    fun greet(): String {\n" ++
  "        return \"Hello, $name!\"\n" ++
  "    }\n" ++
  "}\n"

def testParserNew : IO Unit := do
  let parser ← TSParser.new
  let _ := parser
  IO.println "  testParserNew: PASS"

def testJavaParse : IO Unit := do
  let parser ← TSParser.new
  let lang ← treeSitterJava
  let ok ← parser.setLanguage lang
  if !ok then throw (IO.userError "testJavaParse: FAIL - setLanguage returned false")
  let tree ← parser.parseString javaSource
  let root ← tree.rootNode
  let rootType ← root.type
  if rootType != "program" then
    throw (IO.userError s!"testJavaParse: FAIL - root type is '{rootType}', expected 'program'")
  let isNull ← root.isNull
  if isNull then throw (IO.userError "testJavaParse: FAIL - root is null")
  let isNamed ← root.isNamed
  if !isNamed then throw (IO.userError "testJavaParse: FAIL - root is not named")
  IO.println "  testJavaParse: PASS"

def testPythonParse : IO Unit := do
  let parser ← TSParser.new
  let lang ← treeSitterPython
  let ok ← parser.setLanguage lang
  if !ok then throw (IO.userError "testPythonParse: FAIL - setLanguage returned false")
  let tree ← parser.parseString pythonSource
  let root ← tree.rootNode
  let rootType ← root.type
  if rootType != "module" then
    throw (IO.userError s!"testPythonParse: FAIL - root type is '{rootType}', expected 'module'")
  IO.println "  testPythonParse: PASS"

def testKotlinParse : IO Unit := do
  let parser ← TSParser.new
  let lang ← treeSitterKotlin
  let ok ← parser.setLanguage lang
  if !ok then throw (IO.userError "testKotlinParse: FAIL - setLanguage returned false")
  let tree ← parser.parseString kotlinSource
  let root ← tree.rootNode
  let rootType ← root.type
  if rootType != "source_file" then
    throw (IO.userError s!"testKotlinParse: FAIL - root type is '{rootType}', expected 'source_file'")
  IO.println "  testKotlinParse: PASS"

def testNodeTraversal : IO Unit := do
  let parser ← TSParser.new
  let lang ← treeSitterJava
  let _ ← parser.setLanguage lang
  let tree ← parser.parseString javaSource
  let root ← tree.rootNode
  let childCount ← root.childCount
  if childCount == 0 then
    throw (IO.userError "testNodeTraversal: FAIL - root has no children")
  let namedCount ← root.namedChildCount
  if namedCount == 0 then
    throw (IO.userError "testNodeTraversal: FAIL - root has no named children")
  let firstChild ← root.namedChild 0
  let childType ← firstChild.type
  if childType != "class_declaration" then
    throw (IO.userError s!"testNodeTraversal: FAIL - first named child is '{childType}', expected 'class_declaration'")
  IO.println s!"  testNodeTraversal: PASS (root has {childCount} children, {namedCount} named)"

def testNodePositions : IO Unit := do
  let parser ← TSParser.new
  let lang ← treeSitterJava
  let _ ← parser.setLanguage lang
  let tree ← parser.parseString javaSource
  let root ← tree.rootNode
  let startRow ← root.startRow
  let startCol ← root.startColumn
  let endRow ← root.endRow
  if startRow != 0 then
    throw (IO.userError s!"testNodePositions: FAIL - startRow is {startRow}, expected 0")
  if startCol != 0 then
    throw (IO.userError s!"testNodePositions: FAIL - startCol is {startCol}, expected 0")
  if endRow == 0 then
    throw (IO.userError "testNodePositions: FAIL - endRow is 0, expected > 0")
  IO.println s!"  testNodePositions: PASS (root spans rows {startRow}-{endRow})"

def testNodeSExpression : IO Unit := do
  let parser ← TSParser.new
  let lang ← treeSitterJava
  let _ ← parser.setLanguage lang
  let tree ← parser.parseString "int x = 1;"
  let root ← tree.rootNode
  let sexp ← root.toString
  if sexp.length == 0 then
    throw (IO.userError "testNodeSExpression: FAIL - empty S-expression")
  if !strContains sexp "program" then
    throw (IO.userError s!"testNodeSExpression: FAIL - S-expression doesn't contain 'program': {sexp}")
  IO.println s!"  testNodeSExpression: PASS"

def testNodeStartEndBytes : IO Unit := do
  let parser ← TSParser.new
  let lang ← treeSitterJava
  let _ ← parser.setLanguage lang
  let tree ← parser.parseString javaSource
  let root ← tree.rootNode
  let startByte ← root.startByte
  let endByte ← root.endByte
  if startByte != 0 then
    throw (IO.userError s!"testNodeStartEndBytes: FAIL - startByte is {startByte}, expected 0")
  if endByte == 0 then
    throw (IO.userError "testNodeStartEndBytes: FAIL - endByte is 0")
  IO.println s!"  testNodeStartEndBytes: PASS (root spans bytes {startByte}-{endByte})"

def testJavaClassChildren : IO Unit := do
  let parser ← TSParser.new
  let lang ← treeSitterJava
  let _ ← parser.setLanguage lang
  let tree ← parser.parseString javaSource
  let root ← tree.rootNode
  let classDecl ← root.namedChild 0
  let classType ← classDecl.type
  if classType != "class_declaration" then
    throw (IO.userError s!"testJavaClassChildren: FAIL - expected class_declaration, got {classType}")
  let classChildCount ← classDecl.namedChildCount
  if classChildCount < 2 then
    throw (IO.userError s!"testJavaClassChildren: FAIL - class has {classChildCount} named children, expected >= 2")
  -- Find the identifier child (class name)
  let mut foundName := false
  for i in List.range classChildCount.toNat do
    let child ← classDecl.namedChild i.toUInt32
    let childType ← child.type
    if childType == "identifier" then
      foundName := true
  if !foundName then
    throw (IO.userError "testJavaClassChildren: FAIL - no identifier child found in class_declaration")
  IO.println s!"  testJavaClassChildren: PASS ({classChildCount} named children in class)"

def testQueryJava : IO Unit := do
  let lang ← treeSitterJava
  let parser ← TSParser.new
  let _ ← parser.setLanguage lang
  let tree ← parser.parseString javaSource
  let root ← tree.rootNode
  let query ← TSQuery.new lang "(class_declaration name: (identifier) @name) @decl"
  let cursor ← TSQueryCursor.new
  cursor.exec query root
  let mut matchCount : Nat := 0
  let mut className := ""
  let mut done := false
  while !done do
    let result ← cursor.nextMatch
    match result with
    | none => done := true
    | some (_, _, captures) =>
      matchCount := matchCount + 1
      for (captureIdx, captureNode) in captures do
        let captureName ← query.captureName captureIdx
        if captureName == "name" then
          -- Extract the text using byte offsets
          let startByte ← captureNode.startByte
          let endByte ← captureNode.endByte
          className := (javaSource.toSubstring.drop startByte.toNat).take (endByte.toNat - startByte.toNat) |>.toString
  if matchCount == 0 then
    throw (IO.userError "testQueryJava: FAIL - no matches found")
  if className != "UserService" then
    throw (IO.userError s!"testQueryJava: FAIL - class name is '{className}', expected 'UserService'")
  IO.println s!"  testQueryJava: PASS (found {matchCount} match(es), class name: {className})"

def runAllTests : IO Unit := do
  IO.println "Running Tree-Sitter FFI tests..."
  IO.println ""
  testParserNew
  testJavaParse
  testPythonParse
  testKotlinParse
  testNodeTraversal
  testNodePositions
  testNodeSExpression
  testNodeStartEndBytes
  testJavaClassChildren
  testQueryJava
  IO.println ""
  IO.println "All FFI tests passed! (10 tests)"

end Test.TS.FFI
