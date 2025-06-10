# XcresultParser Makefile

SWIFT_BUILD_FLAGS = -c release
INSTALL_PATH = /usr/local/bin

.PHONY: build test clean install uninstall help example

# Default target
all: build

# Build the project
build:
	@echo "🔨 Building XcresultParser..."
	swift build $(SWIFT_BUILD_FLAGS)
	@echo "✅ Build completed successfully!"

# Build for debug
build-debug:
	@echo "🔨 Building XcresultParser (debug)..."
	swift build
	@echo "✅ Debug build completed!"

# Run tests
test:
	@echo "🧪 Running tests..."
	swift test
	@echo "✅ All tests passed!"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	swift package clean
	@echo "✅ Clean completed!"

# Install the CLI tool
install: build
	@echo "📦 Installing xcresult-cli..."
	cp .build/release/xcresult-cli $(INSTALL_PATH)/xcresult-cli
	@echo "✅ xcresult-cli installed to $(INSTALL_PATH)/xcresult-cli"

# Uninstall the CLI tool
uninstall:
	@echo "🗑️  Uninstalling xcresult-cli..."
	rm -f $(INSTALL_PATH)/xcresult-cli
	@echo "✅ xcresult-cli uninstalled"

# Generate Xcode project
xcode:
	@echo "🔧 Generating Xcode project..."
	swift package generate-xcodeproj
	@echo "✅ Xcode project generated!"

# Show example usage
example:
	@echo "📖 Example Usage:"
	@echo ""
	@echo "# Parse an XCResult bundle"
	@echo "xcresult-cli parse MyApp.xcresult"
	@echo ""
	@echo "# Get coverage information"
	@echo "xcresult-cli coverage MyApp.xcresult --level target --test-type unit"
	@echo ""
	@echo "# Extract attachments"
	@echo "xcresult-cli attachments MyApp.xcresult --output ./attachments"
	@echo ""
	@echo "# Export comprehensive data"
	@echo "xcresult-cli export MyApp.xcresult --output ./reports --include-attachments"
	@echo ""
	@echo "# List test tags"
	@echo "xcresult-cli tags MyApp.xcresult --filter smoke"

# Show help
help:
	@echo "🚀 XcresultParser Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  build         Build the project in release mode"
	@echo "  build-debug   Build the project in debug mode"
	@echo "  test          Run all tests"
	@echo "  clean         Clean build artifacts"
	@echo "  install       Install xcresult-cli to $(INSTALL_PATH)"
	@echo "  uninstall     Remove xcresult-cli from $(INSTALL_PATH)"
	@echo "  xcode         Generate Xcode project"
	@echo "  example       Show example usage"
	@echo "  help          Show this help message"
	@echo ""
	@echo "Usage examples:"
	@echo "  make build"
	@echo "  make test"
	@echo "  make install"

# Quick development setup
dev-setup: build-debug test
	@echo "🎉 Development setup completed!"

# Release preparation
release: clean test build
	@echo "🚀 Release build completed!"
	@echo "📦 Binary location: .build/release/xcresult-cli"

# Lint and format (if you add swiftlint later)
lint:
	@echo "🔍 Linting code..."
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint; \
	else \
		echo "⚠️  SwiftLint not installed. Install with: brew install swiftlint"; \
	fi

# Check dependencies
deps:
	@echo "📋 Checking dependencies..."
	swift package show-dependencies
	@echo "✅ Dependencies check completed!"

# Update dependencies
update-deps:
	@echo "⬆️  Updating dependencies..."
	swift package update
	@echo "✅ Dependencies updated!"
