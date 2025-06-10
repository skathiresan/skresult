import Foundation

/// Examples demonstrating how to use XcresultParser
public class ExampleUsage {
    
    /// Example: Parse an XCResult bundle and extract basic information
    public static func basicParsing() throws {
        let parser = XcresultParser()
        let xcresultPath = "MyApp.xcresult"
        
        let result = try parser.parse(xcresultPath: xcresultPath)
        
        print("Overall Coverage: \(result.overallCoverage?.percentage ?? 0)%")
        print("Number of test suites: \(result.testSuites.count)")
        print("Number of attachments: \(result.attachments.count)")
        print("Test tags found: \(result.tags.map { $0.name }.joined(separator: ", "))")
    }
    
    /// Example: Analyze coverage data in detail
    public static func analyzeCoverage() throws {
        let parser = XcresultParser()
        let xcresultPath = "MyApp.xcresult"
        
        let result = try parser.parse(xcresultPath: xcresultPath)
        
        // Overall coverage analysis
        if let overall = result.overallCoverage {
            print("=== Overall Coverage ===")
            print("Coverage: \(overall.percentage)%")
            print("Lines covered: \(overall.linesCovered)/\(overall.linesTotal)")
            print("Functions covered: \(overall.functionsCovered)/\(overall.functionsTotal)")
        }
        
        // Unit test coverage
        if let unitCoverage = result.unitTestCoverage {
            print("\n=== Unit Test Coverage ===")
            print("Coverage: \(unitCoverage.percentage)%")
            
            // Target-level analysis
            for target in unitCoverage.targets {
                print("\nTarget: \(target.name)")
                print("  Coverage: \(target.percentage)%")
                
                // File-level analysis for low coverage files
                let lowCoverageFiles = target.files.filter { $0.percentage < 80.0 }
                if !lowCoverageFiles.isEmpty {
                    print("  Files with low coverage:")
                    for file in lowCoverageFiles {
                        print("    \(file.name): \(file.percentage)%")
                    }
                }
            }
        }
        
        // UI test coverage
        if let uiCoverage = result.uiTestCoverage {
            print("\n=== UI Test Coverage ===")
            print("Coverage: \(uiCoverage.percentage)%")
        }
    }
    
    /// Example: Extract and analyze test results
    public static func analyzeTestResults() throws {
        let parser = XcresultParser()
        let xcresultPath = "MyApp.xcresult"
        
        let result = try parser.parse(xcresultPath: xcresultPath)
        
        print("=== Test Results Analysis ===")
        
        for suite in result.testSuites {
            print("\nTest Suite: \(suite.name)")
            print("Duration: \(suite.duration)s")
            print("Tests: \(suite.testCases.count)")
            
            let passed = suite.testCases.filter { $0.status == TestStatus.passed }.count
            let failed = suite.testCases.filter { $0.status == TestStatus.failed }.count
            let skipped = suite.testCases.filter { $0.status == TestStatus.skipped }.count
            
            print("  Passed: \(passed)")
            print("  Failed: \(failed)")
            print("  Skipped: \(skipped)")
            
            // Show failed tests
            let failedTests = suite.testCases.filter { $0.status == TestStatus.failed }
            if !failedTests.isEmpty {
                print("  Failed tests:")
                for test in failedTests {
                    print("    - \(test.name) (\(test.duration)s)")
                    if let message = test.failureMessage {
                        print("      Error: \(message)")
                    }
                }
            }
        }
    }
    
    /// Example: Work with test attachments
    public static func processAttachments() throws {
        let parser = XcresultParser()
        let xcresultPath = "MyApp.xcresult"
        
        let result = try parser.parse(xcresultPath: xcresultPath)
        
        print("=== Test Attachments ===")
        print("Total attachments: \(result.attachments.count)")
        
        // Group attachments by type
        let screenshots = result.attachments.filter { $0.type == AttachmentType.screenshot }
        let logs = result.attachments.filter { $0.type == AttachmentType.log }
        let dataFiles = result.attachments.filter { $0.type == AttachmentType.data }
        
        print("Screenshots: \(screenshots.count)")
        print("Logs: \(logs.count)")
        print("Data files: \(dataFiles.count)")
        
        // Show attachment details
        for attachment in result.attachments.prefix(5) {
            print("\nAttachment: \(attachment.name)")
            print("  Type: \(attachment.type)")
            print("  Size: \(attachment.sizeInBytes) bytes")
            print("  Test: \(attachment.testName ?? "Unknown")")
        }
    }
    
    /// Example: Filter tests by tags
    public static func filterByTags() throws {
        let parser = XcresultParser()
        let xcresultPath = "MyApp.xcresult"
        
        let result = try parser.parse(xcresultPath: xcresultPath)
        
        print("=== Test Tags Analysis ===")
        print("Available tags: \(result.tags.map { $0.name }.joined(separator: ", "))")
        
        // Find tests with specific tags
        let smokeTests = result.testsWithTag("smoke")
        let regressionTests = result.testsWithTag("regression")
        
        print("\nSmoke tests: \(smokeTests.count)")
        print("Regression tests: \(regressionTests.count)")
        
        // Show test distribution by tags
        for tag in result.tags {
            let testsWithTag = result.testsWithTag(tag.name)
            print("\nTag '\(tag.name)': \(testsWithTag.count) tests")
            
            if testsWithTag.count <= 5 {
                for test in testsWithTag {
                    print("  - \(test.name)")
                }
            }
        }
    }
    
    /// Example: Export results to different formats
    public static func exportResults() throws {
        let parser = XcresultParser()
        let xcresultPath = "MyApp.xcresult"
        
        let result = try parser.parse(xcresultPath: xcresultPath)
        let exporter = XCResultExporter()
        
        // Export coverage to JSON
        let coverageJSON = URL(fileURLWithPath: "coverage.json")
        try exporter.exportCoverage(result, to: coverageJSON, format: .json)
        print("Exported coverage to JSON: coverage.json")
        
        // Export test results to CSV
        let testResultsCSV = URL(fileURLWithPath: "test_results.csv")
        try exporter.exportTestResults(result, to: testResultsCSV, format: .csv)
        print("Exported test results to CSV: test_results.csv")
        
        // Export coverage to HTML report
        let coverageHTML = URL(fileURLWithPath: "coverage_report.html")
        try exporter.exportCoverage(result, to: coverageHTML, format: .html)
        print("Exported coverage to HTML: coverage_report.html")
        
        // Export attachments
        let attachmentsDir = URL(fileURLWithPath: "export_attachments")
        try exporter.exportAttachments(result.attachments, to: attachmentsDir)
        print("Exported attachments to: export_attachments/")
    }
    
    /// Example: Performance analysis
    public static func performanceAnalysis() throws {
        let parser = XcresultParser()
        let xcresultPath = "MyApp.xcresult"
        
        let result = try parser.parse(xcresultPath: xcresultPath)
        
        print("=== Performance Analysis ===")
        
        // Overall test duration
        let totalDuration = result.totalDuration
        print("Total test execution time: \(totalDuration)s")
        
        // Slowest tests
        let slowestTests = result.slowestTests(count: 10)
        print("\nTop 10 slowest tests:")
        for (index, test) in slowestTests.enumerated() {
            print("\(index + 1). \(test.name): \(test.duration)s")
        }
        
        // Average test duration
        let avgDuration = result.averageTestDuration
        print("\nAverage test duration: \(String(format: "%.2f", avgDuration))s")
        
        // Tests by status
        let passedTests = result.tests(withStatus: TestStatus.passed)
        let failedTests = result.tests(withStatus: TestStatus.failed)
        let skippedTests = result.tests(withStatus: TestStatus.skipped)
        
        print("\nTest results summary:")
        print("  Passed: \(passedTests.count)")
        print("  Failed: \(failedTests.count)")
        print("  Skipped: \(skippedTests.count)")
        
        let totalTests = passedTests.count + failedTests.count + skippedTests.count
        if totalTests > 0 {
            let successRate = Double(passedTests.count) / Double(totalTests) * 100
            print("  Success rate: \(String(format: "%.1f", successRate))%")
        }
    }
}

// MARK: - Command Line Usage Examples

/// Example command-line usage patterns
public struct CLIExamples {
    
    public static let examples = [
        "# Basic parsing",
        "xcresult-cli parse MyApp.xcresult",
        "",
        "# Get coverage information",
        "xcresult-cli coverage MyApp.xcresult --level target --test-type unit",
        "",
        "# Extract attachments",
        "xcresult-cli attachments MyApp.xcresult --output ./attachments",
        "",
        "# Export comprehensive data",
        "xcresult-cli export MyApp.xcresult --output ./reports --include-attachments",
        "",
        "# List test tags",
        "xcresult-cli tags MyApp.xcresult --filter smoke",
        "",
        "# Generate HTML report",
        "xcresult-cli export MyApp.xcresult --format html --output report.html"
    ]
}
