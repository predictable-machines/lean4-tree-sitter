namespace TreeSitter.FFI

opaque TSParserPointed : NonemptyType
def TSParser := TSParserPointed.type
instance : Nonempty TSParser := TSParserPointed.property

opaque TSTreePointed : NonemptyType
def TSTree := TSTreePointed.type
instance : Nonempty TSTree := TSTreePointed.property

opaque TSNodePointed : NonemptyType
def TSNode := TSNodePointed.type
instance : Nonempty TSNode := TSNodePointed.property

opaque TSLanguagePointed : NonemptyType
def TSLanguage := TSLanguagePointed.type
instance : Nonempty TSLanguage := TSLanguagePointed.property

opaque TSQueryPointed : NonemptyType
def TSQuery := TSQueryPointed.type
instance : Nonempty TSQuery := TSQueryPointed.property

opaque TSQueryCursorPointed : NonemptyType
def TSQueryCursor := TSQueryCursorPointed.type
instance : Nonempty TSQueryCursor := TSQueryCursorPointed.property

end TreeSitter.FFI
