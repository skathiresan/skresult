# XcresultParser Documentation

## Overview

XcresultParser is a comprehensive Swift package for parsing Xcode result bundles (.xcresult files) with advanced coverage analysis, test result processing, and attachment extraction capabilities.

## Features

### 🎯 Coverage Analysis
- **Multi-level Coverage**: File, target, and overall coverage metrics
- **Test Type Separation**: Separate analysis for unit tests and UI tests
- **Coverage Comparison**: Delta analysis between different test types
- **Low Coverage Detection**: Identify files that need more testing

### 🧪 Test Result Processing
- **Comprehensive Test Data**: Extract test suites, cases, and metadata
- **Test Status Tracking**: Pass/fail/skip status with failure messages
- **Duration Analysis**: Test timing and performance metrics
- **Tag Support**: Parse and organize tests by tags

### 📎 Attachment Management
- **Universal Attachment Support**: Screenshots, logs, and custom attachments
- **Metadata Preservation**: Timestamps, type information, and test associations
- **Bulk Export**: Extract all attachments with organized file structure
- **Type-based Filtering**: Separate screenshots from logs and other content

### 📊 Export & Reporting
- **Multiple Formats**: JSON, CSV, and HTML export options
- **Interactive Reports**: Rich HTML reports with coverage visualization
- **Structured Data**: Machine-readable formats for CI/CD integration
- **Custom Analysis**: Extensible API for custom data processing

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/XcresultParser.git", from: "1.0.0")
]
```

### Command Line Tool

Build and install the CLI tool:

```bash
make build
make install
```

## Quick Start

### Using the Swift API

```swift
import XcresultParser

// Parse an XCResult bundle
let parser = XcresultParser()
let result = try parser.parse(xcresultPath: "MyApp.xcresult")

// Access coverage data
print("Overall line coverage: \(result.coverage.overall.lineCoverage * 100)%")
print("Unit test coverage: \(result.coverage.unitTestCoverage.overall.lineCoverage * 100)%")
print("UI test coverage: \(result.coverage.uiTestCoverage.overall.lineCoverage * 100)%")

// Analyze test results
print("Total tests: \(result.testData.testSuites.reduce(0) { $0 + $1.tests.count })")
print("Failed tests: \(result.failedTests.count)")

// Process attachments
print("Total attachments: \(result.attachments.count)")
print("Screenshots: \(result.attachments.screenshots.count)")
```

### Using the Command Line

```bash
# Basic parsing
xcresult-cli parse MyApp.xcresult

# Coverage analysis
xcresult-cli coverage MyApp.xcresult --level file --test-type unit --format json

# Extract attachments
xcresult-cli attachments MyApp.xcresult --output ./test-attachments --include-metadata

# Export comprehensive report
xcresult-cli export MyApp.xcresult --output ./reports --include-attachments --generate-reports
```

## API Reference

### Core Classes

#### `XcresultParser`
Main parsing class for XCResult bundles.

```swift
public class XcresultParser {
    public init()
    public func parse(xcresultPath: String) throws -> ParsedXCResult
}
```

#### `ParsedXCResult`
Container for all parsed data.

```swift
public struct ParsedXCResult {
    public let coverage: CoverageData
    public let attachments: [TestAttachment]
    public let testData: TestData
    public let metadata: XCResultMetadata
}
```

### Coverage Data Structures

#### `CoverageData`
Comprehensive coverage information.

```swift
public struct CoverageData {
    public let overall: OverallCoverage
    public let targets: [TargetCoverage]
    public let files: [FileCoverage]
    public let unitTestCoverage: TestTypeCoverage
    public let uiTestCoverage: TestTypeCoverage
}
```

#### `OverallCoverage`
High-level coverage metrics.

```swift
public struct OverallCoverage {
    public let lineCoverage: Double        // 0.0 to 1.0
    public let functionCoverage: Double    // 0.0 to 1.0
    public let branchCoverage: Double?     // Optional branch coverage
    public let executableLines: Int
    public let coveredLines: Int
    public let executableFunctions: Int
    public let coveredFunctions: Int
}
```

### Test Data Structures

#### `TestData`
Complete test execution information.

```swift
public struct TestData {
    public let testSuites: [TestSuite]
    public let tags: [TestTag]
}
```

#### `TestCase`
Individual test case information.

```swift
public struct TestCase {
    public let name: String
    public let identifier: String
    public let duration: TimeInterval
    public let status: TestStatus
    public let tags: [String]
    public let attachments: [TestAttachment]
    public let failureMessage: String?
}
```

### Attachment Structures

#### `TestAttachment`
Test attachment with metadata.

```swift
public struct TestAttachment {
    public let name: String
    public let filename: String?
    public let uniformTypeIdentifier: String?
    public let timestamp: Date?
    public let data: Data
    public let testIdentifier: String
    public let activityTitle: String?
}
```

## Advanced Usage

### Coverage Analysis

```swift
// Find files with low coverage
let lowCoverageFiles = result.coverage.filesWithLowCoverage(threshold: 0.6)
print("Files with < 60% coverage: \(lowCoverageFiles.count)")

// Compare unit vs UI test coverage
let delta = result.coverage.coverageDelta
print("UI tests add \(delta.lineCoverage * 100)% more coverage")

// Get top covered files
let topFiles = result.coverage.topCoveredFiles(count: 10)
```

### Test Analysis

```swift
// Find slowest tests
let slowest = result.testData.slowestTests(count: 5)
for test in slowest {
    print("\(test.name): \(test.duration)s")
}

// Get tests by tag
let smokeTests = result.tests(withTag: "smoke")
print("Smoke tests: \(smokeTests.count)")

// Analyze test suites by type
let unitSuites = result.testData.testSuites(ofType: .unit)
let uiSuites = result.testData.testSuites(ofType: .ui)
```

### Attachment Processing

```swift
// Group attachments by type
let grouped = result.attachments.groupedByType
for (type, attachments) in grouped {
    print("\(type): \(attachments.count) files")
}

// Extract screenshots only
let screenshots = result.attachments.screenshots
for screenshot in screenshots {
    try screenshot.data.write(to: URL(fileURLWithPath: "screenshots/\(screenshot.filename ?? "screenshot.png")"))
}

// Calculate total attachment size
let totalSize = result.attachments.totalSize
print("Total attachment size: \(totalSize / 1024 / 1024) MB")
```

### Export and Reporting

```swift
let exporter = XCResultExporter()

// Export coverage as HTML report
try exporter.exportCoverage(
    result.coverage,
    to: URL(fileURLWithPath: "coverage.html"),
    format: .html
)

// Export test results as CSV
try exporter.exportTestResults(
    result.testData,
    to: URL(fileURLWithPath: "tests.csv"),
    format: .csv
)

// Export all attachments with metadata
try exporter.exportAttachments(
    result.attachments,
    to: URL(fileURLWithPath: "attachments/"),
    includeMetadata: true
)
```

## Command Line Reference

### `parse` Command

Parse an XCResult bundle and display summary.

```bash
xcresult-cli parse <xcresult-path> [--format json|text] [--output <file>]
```

### `coverage` Command

Extract and analyze coverage data.

```bash
xcresult-cli coverage <xcresult-path> 
    [--level overall|target|file] 
    [--test-type unit|ui|all] 
    [--format json|text] 
    [--output <file>]
```

### `attachments` Command

Extract test attachments.

```bash
xcresult-cli attachments <xcresult-path> 
    --output <directory> 
    [--include-metadata]
```

### `tags` Command

List and filter test tags.

```bash
xcresult-cli tags <xcresult-path> 
    [--filter <tag-name>] 
    [--format json|text]
```

### `export` Command

Comprehensive data export.

```bash
xcresult-cli export <xcresult-path> 
    [--output <directory>] 
    [--format json|csv|html|all] 
    [--include-attachments] 
    [--generate-reports]
```

## Error Handling

The library provides comprehensive error handling:

```swift
do {
    let result = try parser.parse(xcresultPath: "MyApp.xcresult")
    // Process result
} catch XcresultParserError.invalidXCResult(let message) {
    print("Invalid XCResult: \(message)")
} catch XcresultParserError.coverageExtractionFailed(let message) {
    print("Coverage extraction failed: \(message)")
} catch {
    print("Unexpected error: \(error)")
}
```

## Best Practices

### Performance
- Parse XCResult bundles incrementally for large test suites
- Use streaming for attachment extraction when dealing with large files
- Cache parsed results for repeated analysis

### Integration
- Use JSON export format for CI/CD pipeline integration
- Generate HTML reports for human review
- Extract attachments for debugging failed tests

### Analysis
- Set appropriate coverage thresholds based on your project needs
- Use tag-based filtering for targeted test analysis
- Monitor test duration trends over time

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Run `make test` to ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details.
