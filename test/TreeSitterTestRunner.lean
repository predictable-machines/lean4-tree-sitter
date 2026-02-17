import PredictableTreeSitterTest.Index

unsafe def main : IO Unit := do
  Test.TreeSitter.FFI.runAllTests
  IO.println ""
  IO.println "=================================================="
  IO.println ""
  Test.TreeSitter.GrammarSpec.runAllTests
  IO.println ""
  IO.println "=================================================="
  IO.println ""
  Test.TreeSitter.Extract.runAllTests
  IO.println ""
  IO.println "=================================================="
  IO.println ""
  Test.TreeSitter.SourceMap.runAllTests
