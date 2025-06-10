import Foundation

/// Export utilities for XCResult data
public class XCResultExporter {
    
    public init() {}
    
    /// Export coverage data to various formats
    public func exportCoverage(
        _ coverage: ParsedXCResult,
        to url: URL,
        format: ExportFormat = .json
    ) throws {
        switch format {
        case .json:
            try exportCoverageAsJSON(coverage, to: url)
        case .csv:
            try exportCoverageAsCSV(coverage, to: url)
        case .html:
            try exportCoverageAsHTML(coverage, to: url)
        }
    }
    
    /// Export test results to various formats
    public func exportTestResults(
        _ testData: ParsedXCResult,
        to url: URL,
        format: ExportFormat = .json
    ) throws {
        switch format {
        case .json:
            try exportTestResultsAsJSON(testData, to: url)
        case .csv:
            try exportTestResultsAsCSV(testData, to: url)
        case .html:
            try exportTestResultsAsHTML(testData, to: url)
        }
    }
    
    /// Export attachments to directory
    public func exportAttachments(
        _ attachments: [TestAttachment],
        to directory: URL,
        includeMetadata: Bool = true
    ) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        for (index, attachment) in attachments.enumerated() {
            let filename = attachment.filename ?? "attachment_\(index)"
            let fileURL = directory.appendingPathComponent(filename)
            
            try attachment.data.write(to: fileURL)
            
            if includeMetadata {
                let metadataURL = directory.appendingPathComponent("\(filename).metadata.json")
                let metadata = AttachmentExportMetadata(
                    name: attachment.name,
                    testIdentifier: attachment.testIdentifier,
                    activityTitle: attachment.activityTitle,
                    uniformTypeIdentifier: attachment.uniformTypeIdentifier,
                    timestamp: attachment.timestamp,
                    originalFilename: attachment.filename,
                    exportedFilename: filename,
                    size: attachment.data.count
                )
                
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                encoder.dateEncodingStrategy = .iso8601
                
                let metadataData = try encoder.encode(metadata)
                try metadataData.write(to: metadataURL)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func exportCoverageAsJSON(_ coverage: ParsedXCResult, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(coverage)
        try data.write(to: url)
    }
    
    private func exportCoverageAsCSV(_ coverage: ParsedXCResult, to url: URL) throws {
        var csv = "File,Line Coverage,Function Coverage,Executable Lines,Covered Lines\n"
        
        for file in coverage.files {
            csv += "\"\(file.name)\",\(file.lineCoverage),\(file.functionCoverage),\(file.executableLines),\(file.coveredLines)\n"
        }
        
        try csv.write(to: url, atomically: true, encoding: .utf8)
    }
    
    private func exportCoverageAsHTML(_ coverage: ParsedXCResult, to url: URL) throws {
        let html = generateCoverageHTML(coverage)
        try html.write(to: url, atomically: true, encoding: .utf8)
    }
    
    private func exportTestResultsAsJSON(_ testData: ParsedXCResult, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(testData)
        try data.write(to: url)
    }
    
    private func exportTestResultsAsCSV(_ testData: ParsedXCResult, to url: URL) throws {
        var csv = "Test Suite,Test Name,Status,Duration,Tags\n"
        
        for suite in testData.testSuites {
            for test in suite.tests {
                let tags = test.tags.joined(separator: ";")
                csv += "\"\(suite.name)\",\"\(test.name)\",\(test.status),\(test.duration),\"\(tags)\"\n"
            }
        }
        
        try csv.write(to: url, atomically: true, encoding: .utf8)
    }
    
    private func exportTestResultsAsHTML(_ testData: ParsedXCResult, to url: URL) throws {
        let html = generateTestResultsHTML(testData)
        try html.write(to: url, atomically: true, encoding: .utf8)
    }
    
    private func generateCoverageHTML(_ coverage: ParsedXCResult) -> String {
        let overallLine = String(format: "%.2f", (coverage.overall?.lineCoverage ?? 0.0) * 100)
        let overallFunction = String(format: "%.2f", (coverage.overall?.functionCoverage ?? 0.0) * 100)
        
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Coverage Report</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 40px; }
                .summary { background: #f5f5f5; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
                .coverage-table { width: 100%; border-collapse: collapse; }
                .coverage-table th, .coverage-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                .coverage-table th { background-color: #f2f2f2; }
                .high-coverage { background-color: #d4edda; }
                .medium-coverage { background-color: #fff3cd; }
                .low-coverage { background-color: #f8d7da; }
            </style>
        </head>
        <body>
            <h1>Coverage Report</h1>
            <div class="summary">
                <h2>Overall Coverage</h2>
                <p>Line Coverage: \(overallLine)%</p>
                <p>Function Coverage: \(overallFunction)%</p>
                <p>Executable Lines: \(coverage.overall?.executableLines ?? 0)</p>
                <p>Covered Lines: \(coverage.overall?.coveredLines ?? 0)</p>
            </div>
            
            <h2>File Coverage</h2>
            <table class="coverage-table">
                <tr>
                    <th>File</th>
                    <th>Line Coverage</th>
                    <th>Function Coverage</th>
                    <th>Executable Lines</th>
                    <th>Covered Lines</th>
                </tr>
        """
        
        for file in coverage.files {
            let lineCoverage = file.lineCoverage * 100
            let functionCoverage = file.functionCoverage * 100
            let coverageClass = lineCoverage >= 80 ? "high-coverage" : (lineCoverage >= 60 ? "medium-coverage" : "low-coverage")
            
            html += """
                <tr class="\(coverageClass)">
                    <td>\(file.name)</td>
                    <td>\(String(format: "%.2f", lineCoverage))%</td>
                    <td>\(String(format: "%.2f", functionCoverage))%</td>
                    <td>\(file.executableLines)</td>
                    <td>\(file.coveredLines)</td>
                </tr>
            """
        }
        
        html += """
            </table>
        </body>
        </html>
        """
        
        return html
    }
    
    private func generateTestResultsHTML(_ testData: ParsedXCResult) -> String {
        let totalTests = testData.testSuites.reduce(0) { $0 + $1.tests.count }
        let passedTests = testData.testSuites.flatMap { $0.tests }.filter { $0.status == .passed }.count
        let failedTests = testData.testSuites.flatMap { $0.tests }.filter { $0.status == .failed }.count
        let successRate = totalTests > 0 ? Double(passedTests) / Double(totalTests) * 100 : 0.0
        
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Test Results</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 40px; }
                .summary { background: #f5f5f5; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
                .test-table { width: 100%; border-collapse: collapse; }
                .test-table th, .test-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                .test-table th { background-color: #f2f2f2; }
                .passed { background-color: #d4edda; }
                .failed { background-color: #f8d7da; }
                .skipped { background-color: #e2e3e5; }
            </style>
        </head>
        <body>
            <h1>Test Results</h1>
            <div class="summary">
                <h2>Summary</h2>
                <p>Total Tests: \(totalTests)</p>
                <p>Passed: \(passedTests)</p>
                <p>Failed: \(failedTests)</p>
                <p>Success Rate: \(String(format: "%.2f", successRate))%</p>
            </div>
            
            <h2>Test Details</h2>
            <table class="test-table">
                <tr>
                    <th>Test Suite</th>
                    <th>Test Name</th>
                    <th>Status</th>
                    <th>Duration</th>
                    <th>Tags</th>
                </tr>
        """
        
        for suite in testData.testSuites {
            for test in suite.tests {
                let statusClass = test.status == .passed ? "passed" : (test.status == .failed ? "failed" : "skipped")
                let tags = test.tags.joined(separator: ", ")
                
                html += """
                    <tr class="\(statusClass)">
                        <td>\(suite.name)</td>
                        <td>\(test.name)</td>
                        <td>\(test.status)</td>
                        <td>\(String(format: "%.2f", test.duration))s</td>
                        <td>\(tags)</td>
                    </tr>
                """
            }
        }
        
        html += """
            </table>
        </body>
        </html>
        """
        
        return html
    }
}

/// Export format enumeration
public enum ExportFormat {
    case json
    case csv
    case html
}

/// Metadata for exported attachments
struct AttachmentExportMetadata: Codable {
    let name: String
    let testIdentifier: String
    let activityTitle: String?
    let uniformTypeIdentifier: String?
    let timestamp: Date?
    let originalFilename: String?
    let exportedFilename: String
    let size: Int
}
