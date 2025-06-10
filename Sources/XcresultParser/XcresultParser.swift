import Foundation
import XCResultKit

/// Main parser for XCResult bundles
public class XcresultParser {
    
    public init() {}
    
    /// Parse an XCResult bundle and extract all relevant data
    /// - Parameter xcresultPath: Path to the .xcresult bundle
    /// - Returns: Parsed result containing coverage, attachments, and test data
    public func parse(xcresultPath: String) throws -> ParsedXCResult {
        let resultFile = XCResultFile(url: URL(fileURLWithPath: xcresultPath))
        
        guard let invocationRecord = resultFile.getInvocationRecord() else {
            throw XcresultParserError.invalidXCResult("Unable to read invocation record")
        }
        
        let coverageExtractor = CoverageExtractor()
        let attachmentExtractor = AttachmentExtractor()
        let testDataExtractor = TestDataExtractor()
        
        // Extract coverage data
        let (overallCoverage, unitTestCoverage, uiTestCoverage) = try coverageExtractor.extractCoverage(from: invocationRecord, resultFile: resultFile)
        
        // Extract attachments
        let attachments = try attachmentExtractor.extractAttachments(from: invocationRecord, resultFile: resultFile)
        
        // Extract test data and tags
        let (testSuites, tags) = try testDataExtractor.extractTestData(from: invocationRecord, resultFile: resultFile)
        
        return ParsedXCResult(
            overallCoverage: overallCoverage,
            unitTestCoverage: unitTestCoverage,
            uiTestCoverage: uiTestCoverage,
            testSuites: testSuites,
            attachments: attachments,
            tags: tags,
            metadata: ParsedXCResult.Metadata(
                xcresultPath: xcresultPath,
                parseDate: Date(),
                xcodeVersion: nil // XCResultKit doesn't expose xcodeVersion directly
            )
        )
    }
}

/// Errors that can occur during XCResult parsing
public enum XcresultParserError: Error, LocalizedError {
    case invalidXCResult(String)
    case coverageExtractionFailed(String)
    case attachmentExtractionFailed(String)
    case testDataExtractionFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidXCResult(let message):
            return "Invalid XCResult: \(message)"
        case .coverageExtractionFailed(let message):
            return "Coverage extraction failed: \(message)"
        case .attachmentExtractionFailed(let message):
            return "Attachment extraction failed: \(message)"
        case .testDataExtractionFailed(let message):
            return "Test data extraction failed: \(message)"
        }
    }
}
