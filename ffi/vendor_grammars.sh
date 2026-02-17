#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFINITIONS="$SCRIPT_DIR/language_definitions.json"
PARSERS_DIR="$SCRIPT_DIR/parsers"
TS_DIR="$SCRIPT_DIR/tree-sitter"
VENDOR_TMP="$SCRIPT_DIR/.vendor-tmp"

rm -rf "$VENDOR_TMP"
mkdir -p "$VENDOR_TMP" "$PARSERS_DIR"

# Vendor tree-sitter core
core_repo=$(jq -r '.["tree-sitter-core"].repo' "$DEFINITIONS")
core_rev=$(jq -r '.["tree-sitter-core"].rev' "$DEFINITIONS")

echo "Vendoring tree-sitter core from $core_repo@$core_rev"
git clone --depth 1 --branch "$core_rev" "$core_repo" "$VENDOR_TMP/tree-sitter-core"

rm -rf "$TS_DIR/lib"
mkdir -p "$TS_DIR/lib"
cp -r "$VENDOR_TMP/tree-sitter-core/lib/include" "$TS_DIR/lib/"
cp -r "$VENDOR_TMP/tree-sitter-core/lib/src" "$TS_DIR/lib/"

# Vendor each grammar
for lang in $(jq -r 'keys[] | select(. != "tree-sitter-core")' "$DEFINITIONS"); do
  repo=$(jq -r ".[\"$lang\"].repo" "$DEFINITIONS")
  rev=$(jq -r ".[\"$lang\"].rev" "$DEFINITIONS")
  dir=$(jq -r ".[\"$lang\"].directory // empty" "$DEFINITIONS")

  echo "Vendoring $lang from $repo@$rev"
  git clone --depth 1 "$repo" "$VENDOR_TMP/$lang"
  (cd "$VENDOR_TMP/$lang" && git fetch --depth 1 origin "$rev" && git checkout "$rev")

  src_dir="$VENDOR_TMP/$lang/${dir:+$dir/}src"
  rm -rf "$PARSERS_DIR/$lang"
  mkdir -p "$PARSERS_DIR/$lang/src"
  cp "$src_dir"/parser.c "$PARSERS_DIR/$lang/src/"
  [ -f "$src_dir/scanner.c" ] && cp "$src_dir/scanner.c" "$PARSERS_DIR/$lang/src/"
  [ -d "$src_dir/tree_sitter" ] && cp -r "$src_dir/tree_sitter" "$PARSERS_DIR/$lang/src/"
done

rm -rf "$VENDOR_TMP"
echo "Done. Vendored parsers in $PARSERS_DIR, core in $TS_DIR"
