import PredictableTreeSitter.FFI.Types

namespace PredictableTreeSitter.FFI

@[extern "lean_ts_parser_new"]
opaque TSParser.new : IO TSParser

@[extern "lean_ts_parser_set_language"]
opaque TSParser.setLanguage (parser : @& TSParser) (lang : @& TSLanguage) : IO Bool

@[extern "lean_ts_parser_parse_string"]
opaque TSParser.parseString (parser : @& TSParser) (source : @& String) : IO TSTree

end PredictableTreeSitter.FFI
