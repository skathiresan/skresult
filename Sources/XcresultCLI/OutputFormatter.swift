import Foundation
import XcresultParser

/// Formats parsed XCResult data for output
struct OutputFormatter {
    let format: OutputFormat
    
    func formatParsedResult(_ result: ParsedXCResult) throws -> String {
        switch format {
        case .json:
            return try formatAsJSON(result)
        case .text:
            return formatAsText(result)
        }
    }
    
    func formatCoverage(_ result: ParsedXCResult, level: CoverageLevel, testType: TestTypeFilter) throws -> String {
        let coverage: OverallCoverage?
        
        switch testType {
        case .unit:
            coverage = result.unitTestCoverage
        case .ui:
            coverage = result.uiTestCoverage
        case .all:
            coverage = result.overallCoverage
        }
        
        guard let coverage = coverage else {
            return format == .json ? "{}" : "No coverage data available\n"
        }
        
        switch format {
        case .json:
            return try formatCoverageAsJSON(coverage, level: level, testType: testType)
        case .text:
            return formatCoverageAsText(coverage, level: level, testType: testType)
        }
    }
    
    func formatTags(_ tags: [TestTag]) throws -> String {
        switch format {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(tags)
            return String(data: data, encoding: .utf8) ?? ""
        case .text:
            return formatTagsAsText(tags)
        }
    }
    
    // MARK: - JSON Formatting
    
    private func formatAsJSON(_ result: ParsedXCResult) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(result)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    private func formatCoverageAsJSON(_ coverage: OverallCoverage, level: CoverageLevel, testType: TestTypeFilter) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(coverage)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    // MARK: - Text Formatting
    
    private func formatAsText(_ result: ParsedXCResult) -> String {
        var output = """
        XCResult Parse Summary
        =====================
        
        Path: \(result.metadata.xcresultPath)
        Parse Date: \(result.metadata.parseDate)
        Xcode Version: \(result.metadata.xcodeVersion ?? "Unknown")
        
        """
        
        output += formatCoverageAsText(result.overallCoverage, level: .overall, testType: .all)
        output += "\n\n"
        output += formatTestSummaryAsText(result.testSuites, result.tags)
        output += "\n\n"
        output += formatAttachmentSummaryAsText(result.attachments)
        
        return output
    }
    
    private func formatCoverageAsText(_ coverage: OverallCoverage?, level: CoverageLevel, testType: TestTypeFilter) -> String {
        guard let coverage = coverage else {
            return "Coverage Summary\n================\n\nNo coverage data available\n"
        }
        
        var output = "Coverage Summary\n"
        output += "================\n\n"
        
        output += "Overall Coverage:\n"
        output += "  Line Coverage: \(String(format: "%.2f", coverage.lineCoverage * 100))%\n"
        output += "  Function Coverage: \(String(format: "%.2f", coverage.functionCoverage * 100))%\n"
        output += "  Executable Lines: \(coverage.executableLines)\n"
        output += "  Covered Lines: \(coverage.coveredLines)\n"
        
        return output
    }
    
    private func formatTestSummaryAsText(_ testSuites: [TestSuite], _ tags: [TestTag]) -> String {
        var output = "Test Summary\n"
        output += "============\n\n"
        
        let totalTests = testSuites.reduce(0) { $0 + $1.tests.count }
        let passedTests = testSuites.flatMap { $0.tests }.filter { $0.status == .passed }.count
        let failedTests = testSuites.flatMap { $0.tests }.filter { $0.status == .failed }.count
        let skippedTests = testSuites.flatMap { $0.tests }.filter { $0.status == .skipped }.count
        
        output += "Total Tests: \(totalTests)\n"
        output += "Passed: \(passedTests)\n"
        output += "Failed: \(failedTests)\n"
        output += "Skipped: \(skippedTests)\n"
        output += "Test Suites: \(testSuites.count)\n"
        output += "Tags: \(tags.count)\n"
        
        return output
    }
    
    private func formatAttachmentSummaryAsText(_ attachments: [TestAttachment]) -> String {
        var output = "Attachments Summary\n"
        output += "==================\n\n"
        
        output += "Total Attachments: \(attachments.count)\n"
        
        let typeGroups = Dictionary(grouping: attachments) { $0.uniformTypeIdentifier ?? "unknown" }
        for (type, attachmentsOfType) in typeGroups {
            output += "  \(type): \(attachmentsOfType.count)\n"
        }
        
        return output
    }
    
    private func formatTagsAsText(_ tags: [TestTag]) -> String {
        var output = "Test Tags\n"
        output += "=========\n\n"
        
        for tag in tags {
            output += "\(tag.name) (\(tag.testIdentifiers.count) tests)\n"
            for identifier in tag.testIdentifiers.prefix(5) {
                output += "  - \(identifier)\n"
            }
            if tag.testIdentifiers.count > 5 {
                output += "  ... and \(tag.testIdentifiers.count - 5) more\n"
            }
            output += "\n"
        }
        
        return output
    }
}


