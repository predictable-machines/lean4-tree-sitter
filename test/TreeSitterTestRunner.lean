import TreeSitterTest.Index

unsafe def main : IO Unit := do
  Test.TS.FFI.runAllTests
  IO.println ""
  IO.println "=================================================="
  IO.println ""
  Test.TS.GrammarSpec.runAllTests
  IO.println ""
  IO.println "=================================================="
  IO.println ""
  Test.TS.Extract.runAllTests
  IO.println ""
  IO.println "=================================================="
  IO.println ""
  Test.TS.SourceMap.runAllTests
