import XCTest
@testable import XcresultParser
import XCResultKit

final class IntegrationTests: XCTestCase {
    
    func testXCResultKitIntegration() throws {
        // Test that we can create XCResultKit objects
        // This verifies the dependency is properly linked
        
        // Create a mock file reference that would typically come from an xcresult bundle
        let fileRef = Reference(id: "test-id")
        XCTAssertEqual(fileRef.id, "test-id")
        
        // Test that our parser initializes correctly
        let parser = XcresultParser()
        XCTAssertNotNil(parser)
        
        // Test that our models work correctly
        let coverage = FileCoverage(
            path: "test/path.swift",
            name: "path.swift", 
            linesCovered: 10,
            linesTotal: 20,
            percentage: 50.0,
            functions: []
        )
        
        XCTAssertEqual(coverage.percentage, 50.0)
        XCTAssertEqual(coverage.path, "test/path.swift")
    }
    
    func testCoverageExtractor() {
        let extractor = CoverageExtractor()
        XCTAssertNotNil(extractor)
        
        // Test that the extractor can be initialized
        // In a real scenario, this would parse actual xcresult data
    }
    
    func testAttachmentExtractor() {
        let extractor = AttachmentExtractor()
        XCTAssertNotNil(extractor)
    }
    
    func testTestDataExtractor() {
        let extractor = TestDataExtractor()
        XCTAssertNotNil(extractor)
    }
    
    func testExporter() {
        let exporter = XCResultExporter()
        XCTAssertNotNil(exporter)
    }
}
