import ArgumentParser
import Foundation
import XcresultParser

struct XcresultCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "xcresult-cli",
        abstract: "A powerful command-line tool for parsing Xcode result bundles (.xcresult)",
        discussion: """
        XcresultCLI provides comprehensive analysis of Xcode test results, including:
        • Unit test and UI test coverage analysis at file, target, and overall levels
        • Test attachment extraction (screenshots, logs, etc.)
        • Test tag parsing and organization
        • Detailed test result analysis with failure information
        • Export capabilities to JSON, CSV, and HTML formats
        
        Examples:
          xcresult-cli parse MyApp.xcresult
          xcresult-cli coverage MyApp.xcresult --level target --test-type unit
          xcresult-cli attachments MyApp.xcresult --output ./attachments
          xcresult-cli tags MyApp.xcresult --filter smoke
        """,
        subcommands: [Parse.self, Coverage.self, Attachments.self, Tags.self, Export.self],
        defaultSubcommand: Parse.self
    )
}

struct Parse: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Parse an XCResult bundle and display summary information"
    )
    
    @Argument(help: "Path to the .xcresult bundle")
    var xcresultPath: String
    
    @Option(name: .shortAndLong, help: "Output format (json, text)")
    var format: OutputFormat = .text
    
    @Option(name: .shortAndLong, help: "Output file path")
    var output: String?
    
    func run() throws {
        let parser = XcresultParser()
        let result = try parser.parse(xcresultPath: xcresultPath)
        
        let formatter = OutputFormatter(format: format)
        let output = try formatter.formatParsedResult(result)
        
        if let outputPath = self.output {
            try output.write(to: URL(fileURLWithPath: outputPath), atomically: true, encoding: .utf8)
            print("Output written to: \(outputPath)")
        } else {
            print(output)
        }
    }
}

struct Coverage: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Extract and display coverage information"
    )
    
    @Argument(help: "Path to the .xcresult bundle")
    var xcresultPath: String
    
    @Option(name: .shortAndLong, help: "Coverage level (overall, target, file)")
    var level: CoverageLevel = .overall
    
    @Option(name: .shortAndLong, help: "Test type (unit, ui, all)")
    var testType: TestTypeFilter = .all
    
    @Option(name: .shortAndLong, help: "Output format (json, text)")
    var format: OutputFormat = .text
    
    @Option(name: .shortAndLong, help: "Output file path")
    var output: String?
    
    func run() throws {
        let parser = XcresultParser()
        let result = try parser.parse(xcresultPath: xcresultPath)
        
        let formatter = OutputFormatter(format: format)
        let output = try formatter.formatCoverage(result, level: level, testType: testType)
        
        if let outputPath = self.output {
            try output.write(to: URL(fileURLWithPath: outputPath), atomically: true, encoding: String.Encoding.utf8)
            print("Coverage report written to: \(outputPath)")
        } else {
            print(output)
        }
    }
}

struct Attachments: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Extract test attachments"
    )
    
    @Argument(help: "Path to the .xcresult bundle")
    var xcresultPath: String
    
    @Option(name: .shortAndLong, help: "Output directory for attachments")
    var output: String
    
    @Flag(name: .long, help: "Include metadata file")
    var includeMetadata = false
    
    func run() throws {
        let parser = XcresultParser()
        let result = try parser.parse(xcresultPath: xcresultPath)
        
        let outputURL = URL(fileURLWithPath: output)
        try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
        
        var savedCount = 0
        for (index, attachment) in result.attachments.enumerated() {
            let filename = attachment.filename ?? "attachment_\(index)"
            let fileURL = outputURL.appendingPathComponent(filename)
            
            try attachment.data.write(to: fileURL)
            savedCount += 1
            
            if includeMetadata {
                let metadataURL = outputURL.appendingPathComponent("\(filename).metadata.json")
                let metadata = AttachmentMetadata(
                    name: attachment.name,
                    testIdentifier: attachment.testIdentifier,
                    activityTitle: attachment.activityTitle,
                    uniformTypeIdentifier: attachment.uniformTypeIdentifier,
                    timestamp: attachment.timestamp
                )
                let metadataData = try JSONEncoder().encode(metadata)
                try metadataData.write(to: metadataURL)
            }
        }
        
        print("Extracted \(savedCount) attachments to: \(output)")
    }
}

struct Tags: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "List test tags and associated tests"
    )
    
    @Argument(help: "Path to the .xcresult bundle")
    var xcresultPath: String
    
    @Option(name: .shortAndLong, help: "Filter by tag name")
    var filter: String?
    
    @Option(name: .shortAndLong, help: "Output format (json, text)")
    var format: OutputFormat = .text
    
    func run() throws {
        let parser = XcresultParser()
        let result = try parser.parse(xcresultPath: xcresultPath)
        
        let tags = filter.map { filterName in
            result.testData.tags.filter { $0.name.contains(filterName) }
        } ?? result.testData.tags
        
        let formatter = OutputFormatter(format: format)
        let output = try formatter.formatTags(tags)
        
        print(output)
    }
}

struct Export: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Export comprehensive XCResult data to various formats",
        discussion: """
        Export all parsed data including coverage, test results, and attachments
        to structured formats for further analysis or reporting.
        """
    )
    
    @Argument(help: "Path to the .xcresult bundle")
    var xcresultPath: String
    
    @Option(name: .shortAndLong, help: "Output directory")
    var output: String = "xcresult_export"
    
    @Option(help: "Export format (json, csv, html, all)")
    var format: ExportFormatOption = .all
    
    @Flag(help: "Include test attachments in export")
    var includeAttachments = false
    
    @Flag(help: "Generate HTML reports")
    var generateReports = false
    
    func run() throws {
        let parser = XcresultParser()
        let result = try parser.parse(xcresultPath: xcresultPath)
        
        let outputURL = URL(fileURLWithPath: output)
        try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
        
        let exporter = XCResultExporter()
        
        if format == .all || format == .json {
            // Export coverage as JSON
            let coverageJSON = outputURL.appendingPathComponent("coverage.json")
            try exporter.exportCoverage(result.coverage, to: coverageJSON, format: .json)
            print("✓ Coverage data exported to: \(coverageJSON.path)")
            
            // Export test results as JSON
            let testResultsJSON = outputURL.appendingPathComponent("test_results.json")
            try exporter.exportTestResults(result.testData, to: testResultsJSON, format: .json)
            print("✓ Test results exported to: \(testResultsJSON.path)")
        }
        
        if format == .all || format == .csv {
            // Export coverage as CSV
            let coverageCSV = outputURL.appendingPathComponent("coverage.csv")
            try exporter.exportCoverage(result.coverage, to: coverageCSV, format: .csv)
            print("✓ Coverage CSV exported to: \(coverageCSV.path)")
            
            // Export test results as CSV
            let testResultsCSV = outputURL.appendingPathComponent("test_results.csv")
            try exporter.exportTestResults(result.testData, to: testResultsCSV, format: .csv)
            print("✓ Test results CSV exported to: \(testResultsCSV.path)")
        }
        
        if format == .all || format == .html || generateReports {
            // Export coverage as HTML
            let coverageHTML = outputURL.appendingPathComponent("coverage_report.html")
            try exporter.exportCoverage(result.coverage, to: coverageHTML, format: .html)
            print("✓ Coverage HTML report: \(coverageHTML.path)")
            
            // Export test results as HTML
            let testResultsHTML = outputURL.appendingPathComponent("test_report.html")
            try exporter.exportTestResults(result.testData, to: testResultsHTML, format: .html)
            print("✓ Test results HTML report: \(testResultsHTML.path)")
        }
        
        if includeAttachments && !result.attachments.isEmpty {
            let attachmentsDir = outputURL.appendingPathComponent("attachments")
            try exporter.exportAttachments(result.attachments, to: attachmentsDir, includeMetadata: true)
            print("✓ \(result.attachments.count) attachments exported to: \(attachmentsDir.path)")
        }
        
        // Create summary file
        let summaryPath = outputURL.appendingPathComponent("summary.txt")
        let summary = createSummaryReport(result)
        try summary.write(to: summaryPath, atomically: true, encoding: .utf8)
        print("✓ Summary report: \(summaryPath.path)")
        
        print("\n🎉 Export completed successfully!")
        print("Output directory: \(outputURL.path)")
    }
    
    private func createSummaryReport(_ result: ParsedXCResult) -> String {
        return """
        XCResult Analysis Summary
        ========================
        
        Source: \(result.metadata.xcresultPath)
        Generated: \(result.metadata.parseDate)
        Xcode Version: \(result.metadata.xcodeVersion ?? "Unknown")
        
        \(result.coverageSummary)
        
        \(result.testSummary)
        
        Attachments: \(result.attachments.count)
        Failed Tests: \(result.failedTests.count)
        Test Tags: \(result.testData.tags.count)
        """
    }
}

// MARK: - Supporting Types

enum OutputFormat: String, CaseIterable, ExpressibleByArgument {
    case json, text
}

enum CoverageLevel: String, CaseIterable, ExpressibleByArgument {
    case overall, target, file
}

enum TestTypeFilter: String, CaseIterable, ExpressibleByArgument {
    case unit, ui, all
}

enum ExportFormatOption: String, CaseIterable, ExpressibleByArgument {
    case json, csv, html, all
}

struct AttachmentMetadata: Codable {
    let name: String
    let testIdentifier: String
    let activityTitle: String?
    let uniformTypeIdentifier: String?
    let timestamp: Date?
}

// Main entry point
XcresultCLI.main()
