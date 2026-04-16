import Lake
open Lake DSL System

package «tree-sitter» where
  version := v!"0.2.2"

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

target ts_typescript.o pkg : FilePath := do
  let src := parsersDir pkg / "typescript" / "src" / "parser.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_typescript.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "typescript" / "src").toString])

target ts_typescript_scanner.o pkg : FilePath := do
  let src := parsersDir pkg / "typescript" / "src" / "scanner.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_typescript_scanner.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "typescript" / "src").toString])

target ts_tsx.o pkg : FilePath := do
  let src := parsersDir pkg / "tsx" / "src" / "parser.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_tsx.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "tsx" / "src").toString])

target ts_tsx_scanner.o pkg : FilePath := do
  let src := parsersDir pkg / "tsx" / "src" / "scanner.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_tsx_scanner.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "tsx" / "src").toString])

target ts_javascript.o pkg : FilePath := do
  let src := parsersDir pkg / "javascript" / "src" / "parser.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_javascript.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "javascript" / "src").toString])

target ts_javascript_scanner.o pkg : FilePath := do
  let src := parsersDir pkg / "javascript" / "src" / "scanner.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_javascript_scanner.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "javascript" / "src").toString])

target ts_go.o pkg : FilePath := do
  let src := parsersDir pkg / "go" / "src" / "parser.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_go.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "go" / "src").toString])

target ts_rust.o pkg : FilePath := do
  let src := parsersDir pkg / "rust" / "src" / "parser.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_rust.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "rust" / "src").toString])

target ts_rust_scanner.o pkg : FilePath := do
  let src := parsersDir pkg / "rust" / "src" / "scanner.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_rust_scanner.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "rust" / "src").toString])

target ts_csharp.o pkg : FilePath := do
  let src := parsersDir pkg / "csharp" / "src" / "parser.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_csharp.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "csharp" / "src").toString])

target ts_csharp_scanner.o pkg : FilePath := do
  let src := parsersDir pkg / "csharp" / "src" / "scanner.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_csharp_scanner.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "csharp" / "src").toString])

target ts_ruby.o pkg : FilePath := do
  let src := parsersDir pkg / "ruby" / "src" / "parser.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_ruby.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "ruby" / "src").toString])

target ts_ruby_scanner.o pkg : FilePath := do
  let src := parsersDir pkg / "ruby" / "src" / "scanner.c"
  let srcJob ← inputBinFile src
  buildO (pkg.irDir / "ffi" / "ts_ruby_scanner.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", (parsersDir pkg / "ruby" / "src").toString])

target ts_shim.o pkg : FilePath := do
  let src := ffiDir pkg / "shim.c"
  let srcJob ← inputBinFile src
  let leanInclude ← getLeanIncludeDir
  buildO (pkg.irDir / "ffi" / "ts_shim.o") srcJob
    (weakArgs := cFlags pkg ++ #["-I", leanInclude.toString])

private def ensureVendored (pkg : Package) : IO Unit := do
  let libC := tsSrcDir pkg / "lib.c"
  let javaC := parsersDir pkg / "java" / "src" / "parser.c"
  unless (← libC.pathExists) && (← javaC.pathExists) do
    IO.println "Vendoring tree-sitter grammars..."
    let result ← IO.Process.output {
      cmd := "bash"
      args := #["vendor_grammars.sh"]
      cwd := ffiDir pkg }
    if result.exitCode ≠ 0 then
      IO.eprintln result.stderr
      throw <| IO.userError "tree-sitter: failed to vendor grammars"

extern_lib «tree-sitter-lean» pkg := do
  ensureVendored pkg
  let name := nameToStaticLib "tree-sitter-lean"
  let core ← fetch <| pkg.target ``ts_core.o
  let java ← fetch <| pkg.target ``ts_java.o
  let python ← fetch <| pkg.target ``ts_python.o
  let pythonScanner ← fetch <| pkg.target ``ts_python_scanner.o
  let kotlin ← fetch <| pkg.target ``ts_kotlin.o
  let kotlinScanner ← fetch <| pkg.target ``ts_kotlin_scanner.o
  let typescript ← fetch <| pkg.target ``ts_typescript.o
  let typescriptScanner ← fetch <| pkg.target ``ts_typescript_scanner.o
  let tsx ← fetch <| pkg.target ``ts_tsx.o
  let tsxScanner ← fetch <| pkg.target ``ts_tsx_scanner.o
  let javascript ← fetch <| pkg.target ``ts_javascript.o
  let javascriptScanner ← fetch <| pkg.target ``ts_javascript_scanner.o
  let go ← fetch <| pkg.target ``ts_go.o
  let rust ← fetch <| pkg.target ``ts_rust.o
  let rustScanner ← fetch <| pkg.target ``ts_rust_scanner.o
  let csharp ← fetch <| pkg.target ``ts_csharp.o
  let csharpScanner ← fetch <| pkg.target ``ts_csharp_scanner.o
  let ruby ← fetch <| pkg.target ``ts_ruby.o
  let rubyScanner ← fetch <| pkg.target ``ts_ruby_scanner.o
  let shim ← fetch <| pkg.target ``ts_shim.o
  buildStaticLib (pkg.staticLibDir / name)
    #[core, java, python, pythonScanner, kotlin, kotlinScanner,
      typescript, typescriptScanner, tsx, tsxScanner,
      javascript, javascriptScanner,
      go, rust, rustScanner, csharp, csharpScanner,
      ruby, rubyScanner, shim]

post_update pkg do
  let rootPkg ← getRootPackage
  if rootPkg.baseName = pkg.baseName then
    return
  let ffi := ffiDir pkg
  let libC := tsSrcDir pkg / "lib.c"
  let javaC := parsersDir pkg / "java" / "src" / "parser.c"
  unless (← libC.pathExists) && (← javaC.pathExists) do
    IO.println "Vendoring tree-sitter grammars..."
    let result ← IO.Process.output {
      cmd := "bash"
      args := #["vendor_grammars.sh"]
      cwd := ffi }
    if result.exitCode ≠ 0 then
      IO.eprintln result.stderr
      error s!"{pkg.baseName}: failed to vendor grammars"

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
