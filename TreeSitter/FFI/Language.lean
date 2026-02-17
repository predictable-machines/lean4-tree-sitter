import PredictableTreeSitter.FFI.Types

namespace PredictableTreeSitter.FFI

@[extern "lean_tree_sitter_java"]
opaque treeSitterJava : IO TSLanguage

@[extern "lean_tree_sitter_python"]
opaque treeSitterPython : IO TSLanguage

@[extern "lean_tree_sitter_kotlin"]
opaque treeSitterKotlin : IO TSLanguage

end PredictableTreeSitter.FFI
