import PredictableTreeSitter.FFI.Types

namespace PredictableTreeSitter.FFI

@[extern "lean_ts_query_new"]
opaque TSQuery.new (lang : @& TSLanguage) (source : @& String) : IO TSQuery

@[extern "lean_ts_query_cursor_new"]
opaque TSQueryCursor.new : IO TSQueryCursor

@[extern "lean_ts_query_cursor_exec"]
opaque TSQueryCursor.exec
    (cursor : @& TSQueryCursor)
    (query : @& TSQuery)
    (node : @& TSNode)
    : IO Unit

structure QueryMatch where
  id : UInt32
  patternIndex : UInt32
  captures : Array (UInt32 × TSNode)

@[extern "lean_ts_query_cursor_next_match"]
opaque TSQueryCursor.nextMatch (cursor : @& TSQueryCursor) : IO (Option (UInt32 × UInt32 × Array (UInt32 × TSNode)))

@[extern "lean_ts_query_capture_name"]
opaque TSQuery.captureName (query : @& TSQuery) (index : UInt32) : IO String

end PredictableTreeSitter.FFI
