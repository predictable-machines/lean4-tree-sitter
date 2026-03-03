import Lake
open Lake DSL System

package «tree-sitter» where
  version := v!"0.1.0"

private def ffiDir (pkg : Package) : FilePath := pkg.dir / "ffi"
private def tsInclude (pkg : Package) : FilePath := ffiDir pkg / "tree-sitter" / "lib" / "include"
private def tsSrcDir (pkg : Package) : FilePath := ffiDir pkg / "tree-sitter" / "lib" / "src"
private def parsersDir (pkg : Package) : FilePath := ffiDir pkg / "parsers"

private def cFlags (pkg : Package) : Array String :=
  #["-fPIC", "-O2", "-std=c11",
    "-I", (tsInclude pkg).toString,
    "-I", (tsSrcDir pkg).toString]

target ts_core.o pkg : FilePath := do
  let src := tsSrcDir pkg / "lib.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_core.o") srcJob
    (weakArgs := cFlags pkg)

target ts_java.o pkg : FilePath := do
  let src := parsersDir pkg / "java" / "src" / "parser.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_java.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "java" / "src").toString])

target ts_python.o pkg : FilePath := do
  let src := parsersDir pkg / "python" / "src" / "parser.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_python.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "python" / "src").toString])

target ts_python_scanner.o pkg : FilePath := do
  let src := parsersDir pkg / "python" / "src" / "scanner.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_python_scanner.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "python" / "src").toString])

target ts_kotlin.o pkg : FilePath := do
  let src := parsersDir pkg / "kotlin" / "src" / "parser.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_kotlin.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "kotlin" / "src").toString])

target ts_kotlin_scanner.o pkg : FilePath := do
  let src := parsersDir pkg / "kotlin" / "src" / "scanner.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_kotlin_scanner.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "kotlin" / "src").toString])

target ts_shim.o pkg : FilePath := do
  let src := ffiDir pkg / "shim.c"
  let srcJob ← inputBinFile src
  let leanInclude ← getLeanIncludeDir
  buildO (pkg.irDir / "ffi" / "ts_shim.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", leanInclude.toString])

extern_lib «tree-sitter-lean» pkg := do
  let name := nameToStaticLib "tree-sitter-lean"
  let core ← fetch <| pkg.target ``ts_core.o
  let java ← fetch <| pkg.target ``ts_java.o
  let python ← fetch <| pkg.target ``ts_python.o
  let pythonScanner ← fetch <| pkg.target ``ts_python_scanner.o
  let kotlin ← fetch <| pkg.target ``ts_kotlin.o
  let kotlinScanner ← fetch <| pkg.target ``ts_kotlin_scanner.o
  let shim ← fetch <| pkg.target ``ts_shim.o
  buildStaticLib (pkg.staticLibDir / name)
    #[core, java, python, pythonScanner, kotlin, kotlinScanner, shim]

@[default_target]
lean_lib TreeSitter where
  roots := #[`TreeSitter]
  extraDepTargets := #[``«tree-sitter-lean»]

lean_lib TreeSitterTest where
  srcDir := "test"
  extraDepTargets := #[``«tree-sitter-lean»]

lean_exe tree_sitter_test_runner where
  root := `TreeSitterTestRunner
  srcDir := "test"
