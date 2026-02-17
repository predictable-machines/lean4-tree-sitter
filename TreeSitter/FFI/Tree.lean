import PredictableTreeSitter.FFI.Types

namespace PredictableTreeSitter.FFI

@[extern "lean_ts_tree_root_node"]
opaque TSTree.rootNode (tree : @& TSTree) : IO TSNode

end PredictableTreeSitter.FFI
