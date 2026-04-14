import TreeSitter.Extract.Index

namespace Test.TS.Extract

open TreeSitter
open TreeSitter.Extract

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

def testExtractJava : IO Unit := do
  let decls ← extractJava javaSource
  let first ← match decls[0]? with
    | some d => pure d
    | none => throw (IO.userError "testExtractJava: FAIL - no declarations found")
  if first.name != "UserService" then
    throw (IO.userError s!"testExtractJava: FAIL - expected 'UserService', got '{first.name}'")
  if first.declType != .class_ then
    throw (IO.userError s!"testExtractJava: FAIL - expected class_, got {repr first.declType}")
  if first.source.startLine != 1 then
    throw (IO.userError s!"testExtractJava: FAIL - expected startLine 1, got {first.source.startLine}")
  if first.children.size == 0 then
    throw (IO.userError "testExtractJava: FAIL - class has no children")
  IO.println s!"  testExtractJava: PASS (found {decls.size} top-level, {first.children.size} class members)"

def testExtractPython : IO Unit := do
  let decls ← extractPython pythonSource
  if decls.size == 0 then
    throw (IO.userError "testExtractPython: FAIL - no declarations found")
  let mut foundClass := false
  let mut foundHelper := false
  let mut calcChildren : Nat := 0
  for d in decls do
    if d.name == "Calculator" && d.declType == .class_ then
      foundClass := true
      calcChildren := d.children.size
    if d.name == "helper" && d.declType == .function_ then foundHelper := true
  if !foundClass then
    throw (IO.userError "testExtractPython: FAIL - class 'Calculator' not found")
  if !foundHelper then
    throw (IO.userError "testExtractPython: FAIL - function 'helper' not found")
  if calcChildren == 0 then
    throw (IO.userError "testExtractPython: FAIL - Calculator has no children")
  IO.println s!"  testExtractPython: PASS (found {decls.size} top-level, Calculator has {calcChildren} methods)"

def testExtractKotlin : IO Unit := do
  let decls ← extractKotlin kotlinSource
  let first ← match decls[0]? with
    | some d => pure d
    | none => throw (IO.userError "testExtractKotlin: FAIL - no declarations found")
  if first.name != "Greeter" then
    throw (IO.userError s!"testExtractKotlin: FAIL - expected 'Greeter', got '{first.name}'")
  if first.declType != .class_ then
    throw (IO.userError s!"testExtractKotlin: FAIL - expected class_, got {repr first.declType}")
  IO.println s!"  testExtractKotlin: PASS (found {decls.size} top-level, {first.children.size} class members)"

def testSourceRanges : IO Unit := do
  let decls ← extractJava javaSource
  let first ← match decls[0]? with
    | some d => pure d
    | none => throw (IO.userError "testSourceRanges: FAIL - no declarations found")
  if first.source.startLine != 1 then
    throw (IO.userError s!"testSourceRanges: FAIL - startLine is {first.source.startLine}, expected 1")
  if first.source.startColumn != 0 then
    throw (IO.userError s!"testSourceRanges: FAIL - startColumn is {first.source.startColumn}, expected 0")
  if first.source.endLine < first.source.startLine then
    throw (IO.userError "testSourceRanges: FAIL - endLine < startLine")
  IO.println s!"  testSourceRanges: PASS (class spans lines {first.source.startLine}-{first.source.endLine})"

def testNestedDeclarations : IO Unit := do
  let decls ← extractJava javaSource
  let classDecl ← match decls[0]? with
    | some d => pure d
    | none => throw (IO.userError "testNestedDeclarations: FAIL - no declarations found")
  let mut hasMethod := false
  let mut hasConstructor := false
  let mut hasField := false
  for child in classDecl.children do
    if child.declType == .method_ then hasMethod := true
    if child.declType == .constructor_ then hasConstructor := true
    if child.declType == .field_ then hasField := true
  if !hasMethod then
    throw (IO.userError "testNestedDeclarations: FAIL - no method found in class")
  if !hasConstructor then
    throw (IO.userError "testNestedDeclarations: FAIL - no constructor found in class")
  if !hasField then
    throw (IO.userError "testNestedDeclarations: FAIL - no field found in class")
  IO.println s!"  testNestedDeclarations: PASS (class has field, constructor, and method)"

def testChildNames : IO Unit := do
  let decls ← extractJava javaSource
  let classDecl ← match decls[0]? with
    | some d => pure d
    | none => throw (IO.userError "testChildNames: FAIL - no declarations found")
  let mut methodName := ""
  let mut constructorName := ""
  for child in classDecl.children do
    if child.declType == .method_ then methodName := child.name
    if child.declType == .constructor_ then constructorName := child.name
  if methodName != "getName" then
    throw (IO.userError s!"testChildNames: FAIL - method name is '{methodName}', expected 'getName'")
  if constructorName != "UserService" then
    throw (IO.userError s!"testChildNames: FAIL - constructor name is '{constructorName}', expected 'UserService'")
  IO.println s!"  testChildNames: PASS (method='{methodName}', constructor='{constructorName}')"

def testPythonMethodNames : IO Unit := do
  let decls ← extractPython pythonSource
  let mut calcMethods : Array String := #[]
  for d in decls do
    if d.name == "Calculator" then
      for child in d.children do
        calcMethods := calcMethods.push child.name
  if calcMethods.size == 0 then
    throw (IO.userError "testPythonMethodNames: FAIL - no methods found in Calculator")
  let mut foundInit := false
  let mut foundAdd := false
  for m in calcMethods do
    if m == "__init__" then foundInit := true
    if m == "add" then foundAdd := true
  if !foundInit then
    throw (IO.userError s!"testPythonMethodNames: FAIL - __init__ not found, got {calcMethods}")
  if !foundAdd then
    throw (IO.userError s!"testPythonMethodNames: FAIL - add not found, got {calcMethods}")
  IO.println s!"  testPythonMethodNames: PASS (Calculator methods: {calcMethods})"

private def typescriptSource : String :=
  "export class UserService {\n" ++
  "    private name: string;\n" ++
  "\n" ++
  "    constructor(name: string) {\n" ++
  "        this.name = name;\n" ++
  "    }\n" ++
  "\n" ++
  "    getName(): string {\n" ++
  "        return this.name;\n" ++
  "    }\n" ++
  "}\n" ++
  "\n" ++
  "interface Serializable {\n" ++
  "    serialize(): string;\n" ++
  "}\n" ++
  "\n" ++
  "enum Color {\n" ++
  "    Red,\n" ++
  "    Green,\n" ++
  "    Blue\n" ++
  "}\n" ++
  "\n" ++
  "type StringOrNumber = string | number;\n" ++
  "\n" ++
  "function helper(x: number): number {\n" ++
  "    return x + 1;\n" ++
  "}\n"

private def tsxSource : String :=
  "interface Props {\n" ++
  "    name: string;\n" ++
  "}\n" ++
  "\n" ++
  "function Greeting(props: Props): JSX.Element {\n" ++
  "    return <div>Hello, {props.name}!</div>;\n" ++
  "}\n" ++
  "\n" ++
  "export class App {\n" ++
  "    render() {\n" ++
  "        return <Greeting name=\"World\" />;\n" ++
  "    }\n" ++
  "}\n"

def testExtractTypescript : IO Unit := do
  let decls ← extractTypescript typescriptSource
  if decls.size == 0 then
    throw (IO.userError "testExtractTypescript: FAIL - no declarations found")
  let mut foundClass := false
  let mut foundInterface := false
  let mut foundEnum := false
  let mut foundTypeAlias := false
  let mut foundFunction := false
  for d in decls do
    if d.name == "UserService" && d.declType == .class_ then foundClass := true
    if d.name == "Serializable" && d.declType == .interface_ then foundInterface := true
    if d.name == "Color" && d.declType == .enum_ then foundEnum := true
    if d.name == "StringOrNumber" && d.declType == .typeAlias then foundTypeAlias := true
    if d.name == "helper" && d.declType == .function_ then foundFunction := true
  if !foundClass then
    throw (IO.userError "testExtractTypescript: FAIL - class 'UserService' not found")
  if !foundInterface then
    throw (IO.userError "testExtractTypescript: FAIL - interface 'Serializable' not found")
  if !foundEnum then
    throw (IO.userError "testExtractTypescript: FAIL - enum 'Color' not found")
  if !foundTypeAlias then
    throw (IO.userError "testExtractTypescript: FAIL - type alias 'StringOrNumber' not found")
  if !foundFunction then
    throw (IO.userError "testExtractTypescript: FAIL - function 'helper' not found")
  IO.println s!"  testExtractTypescript: PASS (found {decls.size} top-level declarations)"

def testExtractTsx : IO Unit := do
  let decls ← extractTsx tsxSource
  if decls.size == 0 then
    throw (IO.userError "testExtractTsx: FAIL - no declarations found")
  let mut foundInterface := false
  let mut foundFunction := false
  let mut foundClass := false
  for d in decls do
    if d.name == "Props" && d.declType == .interface_ then foundInterface := true
    if d.name == "Greeting" && d.declType == .function_ then foundFunction := true
    if d.name == "App" && d.declType == .class_ then foundClass := true
  if !foundInterface then
    throw (IO.userError "testExtractTsx: FAIL - interface 'Props' not found")
  if !foundFunction then
    throw (IO.userError "testExtractTsx: FAIL - function 'Greeting' not found")
  if !foundClass then
    throw (IO.userError "testExtractTsx: FAIL - class 'App' not found")
  IO.println s!"  testExtractTsx: PASS (found {decls.size} top-level declarations, JSX did not interfere)"

private def javascriptSource : String :=
  "class EventEmitter {\n" ++
  "    constructor() {\n" ++
  "        this.listeners = {};\n" ++
  "    }\n" ++
  "\n" ++
  "    on(event, callback) {\n" ++
  "        if (!this.listeners[event]) this.listeners[event] = [];\n" ++
  "        this.listeners[event].push(callback);\n" ++
  "    }\n" ++
  "}\n" ++
  "\n" ++
  "function createEmitter() {\n" ++
  "    return new EventEmitter();\n" ++
  "}\n" ++
  "\n" ++
  "function* range(start, end) {\n" ++
  "    for (let i = start; i < end; i++) yield i;\n" ++
  "}\n"

def testExtractJavascript : IO Unit := do
  let decls ← extractJavascript javascriptSource
  if decls.size == 0 then
    throw (IO.userError "testExtractJavascript: FAIL - no declarations found")
  let mut foundClass := false
  let mut foundFunction := false
  let mut foundGenerator := false
  for d in decls do
    if d.name == "EventEmitter" && d.declType == .class_ then foundClass := true
    if d.name == "createEmitter" && d.declType == .function_ then foundFunction := true
    if d.name == "range" && d.declType == .function_ then foundGenerator := true
  if !foundClass then
    throw (IO.userError "testExtractJavascript: FAIL - class 'EventEmitter' not found")
  if !foundFunction then
    throw (IO.userError "testExtractJavascript: FAIL - function 'createEmitter' not found")
  if !foundGenerator then
    throw (IO.userError "testExtractJavascript: FAIL - generator function 'range' not found")
  IO.println s!"  testExtractJavascript: PASS (found {decls.size} top-level declarations)"

def runAllTests : IO Unit := do
  IO.println "Running Extraction Engine tests..."
  IO.println ""
  testExtractJava
  testExtractPython
  testExtractKotlin
  testExtractTypescript
  testExtractTsx
  testExtractJavascript
  testSourceRanges
  testNestedDeclarations
  testChildNames
  testPythonMethodNames
  IO.println ""
  IO.println "All Extraction tests passed! (10 tests)"

end Test.TS.Extract
