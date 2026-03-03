import TreeSitter.SourceMap.Index
import TreeSitter.Extract.Index

namespace Test.TS.SourceMap

open TreeSitter
open TreeSitter.SourceMap
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

def testFromDeclarations : IO Unit := do
  let decls ← extractJava javaSource
  let sm := SourceMap.fromDeclarations decls "UserService.java" "Verified.UserService"
  if sm.entries.size == 0 then
    throw (IO.userError "testFromDeclarations: FAIL - empty source map")
  if sm.sourceFile != "UserService.java" then
    throw (IO.userError "testFromDeclarations: FAIL - wrong sourceFile")
  if sm.leanModule != "Verified.UserService" then
    throw (IO.userError "testFromDeclarations: FAIL - wrong leanModule")
  IO.println s!"  testFromDeclarations: PASS ({sm.entries.size} entries)"

def testLookupByDeclName : IO Unit := do
  let decls ← extractJava javaSource
  let sm := SourceMap.fromDeclarations decls "UserService.java" "Verified.UserService"
  match sm.lookupByDeclName "UserService" with
  | some m =>
    if m.source.startLine != 1 then
      throw (IO.userError s!"testLookupByDeclName: FAIL - startLine is {m.source.startLine}, expected 1")
    if m.declType != .class_ then
      throw (IO.userError "testLookupByDeclName: FAIL - wrong declType")
  | none =>
    throw (IO.userError "testLookupByDeclName: FAIL - UserService not found")
  IO.println "  testLookupByDeclName: PASS"

def testLookupByLeanLine : IO Unit := do
  let decls ← extractJava javaSource
  let sm := SourceMap.fromDeclarations decls "UserService.java" "Verified.UserService"
  -- First entry should be at lean line 1
  match sm.lookupByLeanLine 1 with
  | some m =>
    if m.declName != "UserService" then
      throw (IO.userError s!"testLookupByLeanLine: FAIL - expected 'UserService', got '{m.declName}'")
  | none =>
    throw (IO.userError "testLookupByLeanLine: FAIL - no entry at line 1")
  IO.println "  testLookupByLeanLine: PASS"

def testLookupBySource : IO Unit := do
  let decls ← extractJava javaSource
  let sm := SourceMap.fromDeclarations decls "UserService.java" "Verified.UserService"
  let classDecl ← match decls[0]? with
    | some d => pure d
    | none => throw (IO.userError "testLookupBySource: FAIL - no declarations found")
  let classRange : SourceRange := classDecl.source
  match sm.lookupBySource classRange with
  | some m =>
    if m.declName != "UserService" then
      throw (IO.userError s!"testLookupBySource: FAIL - expected 'UserService', got '{m.declName}'")
  | none =>
    throw (IO.userError "testLookupBySource: FAIL - source range not found")
  IO.println "  testLookupBySource: PASS"

def testTraceError : IO Unit := do
  let decls ← extractJava javaSource
  let sm := SourceMap.fromDeclarations decls "UserService.java" "Verified.UserService"
  -- Trace an exact line
  match sm.traceError 1 with
  | some range =>
    if range.startLine != 1 then
      throw (IO.userError s!"testTraceError: FAIL - traced to line {range.startLine}, expected 1")
  | none =>
    throw (IO.userError "testTraceError: FAIL - could not trace line 1")
  -- Trace a line between entries (should find nearest preceding)
  let maxLine := sm.entries.foldl (init := 0) fun acc m => max acc m.lean.line
  match sm.traceError (maxLine + 10) with
  | some _ => pure ()
  | none =>
    throw (IO.userError "testTraceError: FAIL - could not trace line beyond last entry")
  IO.println "  testTraceError: PASS"

def testFilterByType : IO Unit := do
  let decls ← extractJava javaSource
  let sm := SourceMap.fromDeclarations decls "UserService.java" "Verified.UserService"
  let methods := sm.filterByType .method_
  let classes := sm.filterByType .class_
  if classes.size == 0 then
    throw (IO.userError "testFilterByType: FAIL - no classes found")
  if methods.size == 0 then
    throw (IO.userError "testFilterByType: FAIL - no methods found")
  IO.println s!"  testFilterByType: PASS (classes={classes.size}, methods={methods.size})"

def testCompose : IO Unit := do
  -- sm1: source → intermediate (line-based)
  let sm1 : SourceMap := {
    entries := #[
      { source := { startLine := 10, startColumn := 0, endLine := 20, endColumn := 0 }
        lean := { module := "Intermediate", line := 1, column := 0 }
        declName := "foo", declType := .function_ },
      { source := { startLine := 30, startColumn := 0, endLine := 40, endColumn := 0 }
        lean := { module := "Intermediate", line := 2, column := 0 }
        declName := "bar", declType := .function_ }
    ]
    sourceFile := "source.java"
    leanModule := "Intermediate"
  }
  -- sm2: intermediate → lean
  let sm2 : SourceMap := {
    entries := #[
      { source := { startLine := 1, startColumn := 0, endLine := 1, endColumn := 0 }
        lean := { module := "Verified.Output", line := 5, column := 0 }
        declName := "foo", declType := .function_ },
      { source := { startLine := 2, startColumn := 0, endLine := 2, endColumn := 0 }
        lean := { module := "Verified.Output", line := 10, column := 0 }
        declName := "bar", declType := .function_ }
    ]
    sourceFile := "Intermediate"
    leanModule := "Verified.Output"
  }
  let composed := sm1.compose sm2
  if composed.entries.size != 2 then
    throw (IO.userError s!"testCompose: FAIL - expected 2 entries, got {composed.entries.size}")
  if composed.sourceFile != "source.java" then
    throw (IO.userError "testCompose: FAIL - wrong sourceFile")
  if composed.leanModule != "Verified.Output" then
    throw (IO.userError "testCompose: FAIL - wrong leanModule")
  -- First entry should map source line 10 → lean line 5
  let first ← match composed.entries[0]? with
    | some e => pure e
    | none => throw (IO.userError "testCompose: FAIL - no entries in composed map")
  if first.source.startLine != 10 then
    throw (IO.userError s!"testCompose: FAIL - expected source line 10, got {first.source.startLine}")
  if first.lean.line != 5 then
    throw (IO.userError s!"testCompose: FAIL - expected lean line 5, got {first.lean.line}")
  IO.println "  testCompose: PASS"

def runAllTests : IO Unit := do
  IO.println "Running Source Map tests..."
  IO.println ""
  testFromDeclarations
  testLookupByDeclName
  testLookupByLeanLine
  testLookupBySource
  testTraceError
  testFilterByType
  testCompose
  IO.println ""
  IO.println "All Source Map tests passed! (7 tests)"

end Test.TS.SourceMap
