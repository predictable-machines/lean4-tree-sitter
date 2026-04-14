.PHONY: build test vendor-grammars ensure-grammars clean help

# Default target
all: build

# Auto-vendor tree-sitter grammars if missing
ensure-grammars:
	@if [ ! -f ffi/tree-sitter/lib/src/lib.c ] || [ ! -f ffi/parsers/java/src/parser.c ]; then \
		echo "Tree-sitter grammars not found, vendoring..."; \
		cd ffi && bash vendor_grammars.sh; \
	fi

# Build the library
build: ensure-grammars
	lake build

# Run tests
test: ensure-grammars
	lake build tree_sitter_test_runner
	.lake/build/bin/tree_sitter_test_runner

# Vendor tree-sitter grammars (run once, or after updating language_definitions.json)
vendor-grammars:
	cd ffi && bash vendor_grammars.sh

# Clean build artifacts and vendored grammars
clean:
	lake clean
	rm -rf ffi/tree-sitter/lib ffi/parsers/java ffi/parsers/python ffi/parsers/kotlin ffi/parsers/typescript ffi/parsers/tsx ffi/parsers/javascript ffi/parsers/common

# Show help
help:
	@echo "lean4-tree-sitter - Lean 4 Tree-Sitter Bindings"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build            Build the library (default)"
	@echo "  test             Build and run tests"
	@echo "  vendor-grammars  Vendor tree-sitter grammar sources"
	@echo "  clean            Clean build artifacts and vendored grammars"
	@echo "  help             Show this help message"
