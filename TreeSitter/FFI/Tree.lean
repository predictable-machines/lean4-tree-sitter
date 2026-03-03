import TreeSitter.FFI.Types

namespace TreeSitter.FFI

@[extern "lean_ts_tree_root_node"]
opaque TSTree.rootNode (tree : @& TSTree) : IO TSNode

end TreeSitter.FFI
