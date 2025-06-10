import XCTest
@testable import XcresultParser

final class XcresultParserTests: XCTestCase {
    
    func testParserInitialization() {
        let parser = XcresultParser()
        XCTAssertNotNil(parser)
    }
    
    func testCoverageDataModel() {
        let overallCoverage = OverallCoverage(
            lineCoverage: 0.85,
            functionCoverage: 0.90,
            branchCoverage: 0.75,
            executableLines: 100,
            coveredLines: 85,
            executableFunctions: 20,
            coveredFunctions: 18
        )
        
        XCTAssertEqual(overallCoverage.lineCoverage, 0.85)
        XCTAssertEqual(overallCoverage.functionCoverage, 0.90)
        XCTAssertEqual(overallCoverage.branchCoverage, 0.75)
        XCTAssertEqual(overallCoverage.executableLines, 100)
        XCTAssertEqual(overallCoverage.coveredLines, 85)
    }
    
    func testTestCaseModel() {
        let testCase = TestCase(
            name: "testExample",
            identifier: "com.example.test.testExample",
            duration: 1.5,
            status: .passed,
            tags: ["smoke", "unit"],
            attachments: [],
            failureMessage: nil
        )
        
        XCTAssertEqual(testCase.name, "testExample")
        XCTAssertEqual(testCase.status, .passed)
        XCTAssertEqual(testCase.tags.count, 2)
        XCTAssertTrue(testCase.tags.contains("smoke"))
        XCTAssertTrue(testCase.tags.contains("unit"))
    }
    
    func testTestAttachmentModel() {
        let data = "test data".data(using: .utf8)!
        let attachment = TestAttachment(
            name: "screenshot",
            filename: "screenshot.png",
            uniformTypeIdentifier: "public.png",
            timestamp: Date(),
            data: data,
            testIdentifier: "com.example.test.testExample",
            activityTitle: "Take Screenshot"
        )
        
        XCTAssertEqual(attachment.name, "screenshot")
        XCTAssertEqual(attachment.filename, "screenshot.png")
        XCTAssertEqual(attachment.uniformTypeIdentifier, "public.png")
        XCTAssertEqual(attachment.data, data)
    }
    
    func testTestTypeEnum() {
        XCTAssertEqual(TestType.unit, TestType.unit)
        XCTAssertEqual(TestType.ui, TestType.ui)
        XCTAssertNotEqual(TestType.unit, TestType.ui)
    }
    
    func testTestStatusEnum() {
        XCTAssertEqual(TestStatus.passed, TestStatus.passed)
        XCTAssertEqual(TestStatus.failed, TestStatus.failed)
        XCTAssertNotEqual(TestStatus.passed, TestStatus.failed)
    }
    
    func testXcresultParserError() {
        let error = XcresultParserError.invalidXCResult("Test error")
        XCTAssertEqual(error.localizedDescription, "Invalid XCResult: Test error")
        
        let coverageError = XcresultParserError.coverageExtractionFailed("Coverage error")
        XCTAssertEqual(coverageError.localizedDescription, "Coverage extraction failed: Coverage error")
    }
    
    // Test with a mock XCResult bundle (would need actual test data in real scenarios)
    func testParseInvalidPath() {
        let parser = XcresultParser()
        
        XCTAssertThrowsError(try parser.parse(xcresultPath: "/invalid/path.xcresult")) { error in
            // Should throw an error for invalid path
            XCTAssertNotNil(error)
        }
    }
}
