import TreeSitter.FFI.Index
import TreeSitter.Types.Index

namespace TreeSitter.Extract

open TreeSitter.FFI
open TreeSitter

private def extractSubstr (source : String) (startByte endByte : UInt32) : Substring.Raw :=
  { str := source, startPos := ⟨startByte.toNat⟩, stopPos := ⟨endByte.toNat⟩ }

def extractText (source : String) (startByte endByte : UInt32) : String :=
  Substring.Raw.toString (extractSubstr source startByte endByte)

def parseSource (lang : IO TSLanguage) (source : String) : IO TSTree := do
  let parser ← TSParser.new
  let language ← lang
  let ok ← parser.setLanguage language
  if !ok then throw (IO.userError "language version mismatch")
  parser.parseString source

private def isIdentifierType (nodeType : String) : Bool :=
  nodeType == "identifier" || nodeType == "simple_identifier"

/-- Resolve the name of a declaration node using multiple strategies:
    1. Try grammar field "name" (covers most declaration types)
    2. Try field paths: "declarator", "left", "definition" (covers fields, assignments, decorators)
    3. Search direct children for identifier nodes
    4. Search one level deeper for identifier nodes
    5. Try type_identifier as last resort (Kotlin class names)
    Set `debug := true` to log which strategy resolved each name to stderr. -/
partial def findName (node : TSNode) (source : String) (debug : Bool := false) : IO String := do
  let resolve (sub : Substring.Raw) (strategy : String) : IO String := do
    let name := Substring.Raw.toString sub
    if debug then IO.eprintln s!"findName: '{name}' resolved via {strategy}"
    return name
  -- Strategy 1: try common field names that point to the declaration's name
  for fieldName in ["name", "declarator", "left", "definition"] do
    let fieldNode ← node.childByFieldName fieldName
    if !(← fieldNode.isNull) then
      let fieldType ← fieldNode.type
      if isIdentifierType fieldType || fieldType == "type_identifier" then
        return ← resolve (extractSubstr source (← fieldNode.startByte) (← fieldNode.endByte))
          s!"field '{fieldName}' (strategy 1)"
      -- The field node is a wrapper; look for "name" inside it
      let innerName ← fieldNode.childByFieldName "name"
      if !(← innerName.isNull) then
        return ← resolve (extractSubstr source (← innerName.startByte) (← innerName.endByte))
          s!"field '{fieldName}' → inner 'name' (strategy 1)"
      -- Search field node's children for identifiers
      let innerCount ← fieldNode.namedChildCount
      for i in List.range innerCount.toNat do
        let child ← fieldNode.namedChild i.toUInt32
        let t ← child.type
        if isIdentifierType t || t == "type_identifier" then
          return ← resolve (extractSubstr source (← child.startByte) (← child.endByte))
            s!"field '{fieldName}' → child {t} (strategy 1)"
  -- Strategy 2: search direct named children for identifier types
  let count ← node.namedChildCount
  for i in List.range count.toNat do
    let child ← node.namedChild i.toUInt32
    let t ← child.type
    if isIdentifierType t then
      return ← resolve (extractSubstr source (← child.startByte) (← child.endByte))
        s!"direct child {t} (strategy 2)"
  -- Strategy 3: search one level deeper
  for i in List.range count.toNat do
    let child ← node.namedChild i.toUInt32
    let innerCount ← child.namedChildCount
    let innerName ← child.childByFieldName "name"
    if !(← innerName.isNull) then
      return ← resolve (extractSubstr source (← innerName.startByte) (← innerName.endByte))
        "nested 'name' field (strategy 3)"
    for j in List.range innerCount.toNat do
      let gc ← child.namedChild j.toUInt32
      let t ← gc.type
      if isIdentifierType t then
        return ← resolve (extractSubstr source (← gc.startByte) (← gc.endByte))
          s!"nested child {t} (strategy 3)"
  -- Strategy 4: type_identifier as last resort (Kotlin class names when no "name" field)
  for i in List.range count.toNat do
    let child ← node.namedChild i.toUInt32
    let t ← child.type
    if t == "type_identifier" then
      return ← resolve (extractSubstr source (← child.startByte) (← child.endByte))
        "type_identifier (strategy 4)"
  if debug then IO.eprintln "findName: no strategy matched, returning '<anonymous>'"
  return "<anonymous>"

/-- Recursively walk the CST, collecting declarations matched by nodeMapping.
    Matched nodes become Declaration entries with their children collected recursively.
    Unmatched nodes are transparent — the walker recurses through them. -/
partial def walkNode
    (node : TSNode)
    (nodeMapping : String → Option DeclarationType)
    (source : String)
    : IO (Array Declaration) := do
  let isNull ← node.isNull
  if isNull then return #[]
  let nodeType ← node.type
  match nodeMapping nodeType with
  | some declType =>
    let name ← findName node source
    let startRow ← node.startRow
    let startCol ← node.startColumn
    let endRow ← node.endRow
    let endCol ← node.endColumn
    let childCount ← node.childCount
    let mut children : Array Declaration := #[]
    for i in List.range childCount.toNat do
      let child ← node.child i.toUInt32
      let childResults ← walkNode child nodeMapping source
      children := children ++ childResults
    return #[{
      name := name
      declType := declType
      source := {
        startLine := startRow.toNat + 1
        startColumn := startCol.toNat
        endLine := endRow.toNat + 1
        endColumn := endCol.toNat
      }
      children := children
    }]
  | none =>
    let childCount ← node.childCount
    let mut results : Array Declaration := #[]
    for i in List.range childCount.toNat do
      let child ← node.child i.toUInt32
      let childResults ← walkNode child nodeMapping source
      results := results ++ childResults
    return results

def extractDeclarations
    (lang : IO TSLanguage)
    (nodeMapping : String → Option DeclarationType)
    (source : String)
    : IO (Array Declaration) := do
  let tree ← parseSource lang source
  let root ← tree.rootNode
  walkNode root nodeMapping source

-- Language-specific node type string → DeclarationType mappings

def javaNodeMapping : String → Option DeclarationType
  | "class_declaration"           => some .class_
  | "interface_declaration"       => some .interface_
  | "enum_declaration"            => some .enum_
  | "annotation_type_declaration" => some .annotation_
  | "method_declaration"          => some .method_
  | "constructor_declaration"     => some .constructor_
  | "field_declaration"           => some .field_
  | "constant_declaration"        => some .constant_
  | "record_declaration"          => some .class_
  | _ => none

def pythonNodeMapping : String → Option DeclarationType
  | "function_definition"  => some .function_
  | "class_definition"     => some .class_
  | _ => none

def kotlinNodeMapping : String → Option DeclarationType
  | "class_declaration"     => some .class_
  | "object_declaration"    => some .class_
  | "interface_declaration" => some .interface_
  | "function_declaration"  => some .function_
  | "property_declaration"  => some .property_
  | "type_alias"            => some .typeAlias
  | "companion_object"      => some .class_
  | _ => none

def extractJava (source : String) : IO (Array Declaration) :=
  extractDeclarations treeSitterJava javaNodeMapping source

def extractPython (source : String) : IO (Array Declaration) :=
  extractDeclarations treeSitterPython pythonNodeMapping source

def extractKotlin (source : String) : IO (Array Declaration) :=
  extractDeclarations treeSitterKotlin kotlinNodeMapping source

def typescriptNodeMapping : String → Option DeclarationType
  | "class_declaration"            => some .class_
  | "abstract_class_declaration"   => some .class_
  | "interface_declaration"        => some .interface_
  | "enum_declaration"             => some .enum_
  | "type_alias_declaration"       => some .typeAlias
  | "function_declaration"         => some .function_
  | "method_definition"            => some .method_
  | "public_field_definition"      => some .field_
  | "function_signature"           => some .function_
  | "abstract_method_signature"    => some .method_
  | "module"                       => some .module_
  | _ => none

def extractTypescript (source : String) : IO (Array Declaration) :=
  extractDeclarations treeSitterTypescript typescriptNodeMapping source

def extractTsx (source : String) : IO (Array Declaration) :=
  extractDeclarations treeSitterTsx typescriptNodeMapping source

def javascriptNodeMapping : String → Option DeclarationType
  | "class_declaration"            => some .class_
  | "function_declaration"         => some .function_
  | "generator_function_declaration" => some .function_
  | "method_definition"            => some .method_
  | "field_definition"             => some .field_
  | _ => none

def extractJavascript (source : String) : IO (Array Declaration) :=
  extractDeclarations treeSitterJavascript javascriptNodeMapping source

end TreeSitter.Extract
