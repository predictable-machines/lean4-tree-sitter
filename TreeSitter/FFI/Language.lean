import TreeSitter.FFI.Types

namespace TreeSitter.FFI

@[extern "lean_tree_sitter_java"]
opaque treeSitterJava : IO TSLanguage

@[extern "lean_tree_sitter_python"]
opaque treeSitterPython : IO TSLanguage

@[extern "lean_tree_sitter_kotlin"]
opaque treeSitterKotlin : IO TSLanguage

@[extern "lean_tree_sitter_typescript"]
opaque treeSitterTypescript : IO TSLanguage

@[extern "lean_tree_sitter_tsx"]
opaque treeSitterTsx : IO TSLanguage

@[extern "lean_tree_sitter_javascript"]
opaque treeSitterJavascript : IO TSLanguage

@[extern "lean_tree_sitter_go"]
opaque treeSitterGo : IO TSLanguage

@[extern "lean_tree_sitter_rust"]
opaque treeSitterRust : IO TSLanguage

@[extern "lean_tree_sitter_c_sharp"]
opaque treeSitterCSharp : IO TSLanguage

@[extern "lean_tree_sitter_ruby"]
opaque treeSitterRuby : IO TSLanguage

end TreeSitter.FFI
