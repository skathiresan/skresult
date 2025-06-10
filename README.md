# XcresultParser

A Swift package for parsing Xcode result bundles (.xcresult) with comprehensive coverage analysis and test attachment extraction.

## Features

- **Unit Test Coverage Analysis**: Parse coverage data at file, target, and overall levels
- **UI Test Coverage Analysis**: Extract UI test coverage metrics  
- **Test Attachments**: Extract and process xcattachments from test results
- **Test Tags**: Parse and organize test tags and metadata
- **Comprehensive Reporting**: Generate detailed coverage reports

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/XcresultParser.git", from: "1.0.0")
]
```

## Usage

### Command Line Interface

```bash
# Parse an xcresult bundle
xcresult-cli parse MyApp.xcresult

# Export coverage report
xcresult-cli coverage MyApp.xcresult --format json --output coverage.json

# Extract attachments
xcresult-cli attachments MyApp.xcresult --output ./attachments
```

### Swift API

```swift
import XcresultParser

let parser = XcresultParser()
let result = try parser.parse(xcresultPath: "MyApp.xcresult")

// Get overall coverage
let overallCoverage = result.coverage.overall

// Get target-level coverage
let targetCoverage = result.coverage.targets

// Get file-level coverage
let fileCoverage = result.coverage.files

// Extract attachments
let attachments = result.attachments
```

## Requirements

- macOS 12.0+ / iOS 15.0+
- Swift 5.9+
- Xcode 14.0+

## License

MIT License
