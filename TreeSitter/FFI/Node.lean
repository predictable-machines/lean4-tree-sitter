import TreeSitter.FFI.Types

namespace TreeSitter.FFI

@[extern "lean_ts_node_type"]
opaque TSNode.type (node : @& TSNode) : IO String

@[extern "lean_ts_node_child_count"]
opaque TSNode.childCount (node : @& TSNode) : IO UInt32

@[extern "lean_ts_node_named_child_count"]
opaque TSNode.namedChildCount (node : @& TSNode) : IO UInt32

@[extern "lean_ts_node_child"]
opaque TSNode.child (node : @& TSNode) (index : UInt32) : IO TSNode

@[extern "lean_ts_node_named_child"]
opaque TSNode.namedChild (node : @& TSNode) (index : UInt32) : IO TSNode

@[extern "lean_ts_node_start_row"]
opaque TSNode.startRow (node : @& TSNode) : IO UInt32

@[extern "lean_ts_node_start_column"]
opaque TSNode.startColumn (node : @& TSNode) : IO UInt32

@[extern "lean_ts_node_end_row"]
opaque TSNode.endRow (node : @& TSNode) : IO UInt32

@[extern "lean_ts_node_end_column"]
opaque TSNode.endColumn (node : @& TSNode) : IO UInt32

@[extern "lean_ts_node_start_byte"]
opaque TSNode.startByte (node : @& TSNode) : IO UInt32

@[extern "lean_ts_node_end_byte"]
opaque TSNode.endByte (node : @& TSNode) : IO UInt32

@[extern "lean_ts_node_string"]
opaque TSNode.toString (node : @& TSNode) : IO String

@[extern "lean_ts_node_is_null"]
opaque TSNode.isNull (node : @& TSNode) : IO Bool

@[extern "lean_ts_node_is_named"]
opaque TSNode.isNamed (node : @& TSNode) : IO Bool

@[extern "lean_ts_node_child_by_field_name"]
opaque TSNode.childByFieldName (node : @& TSNode) (fieldName : @& String) : IO TSNode

end TreeSitter.FFI
