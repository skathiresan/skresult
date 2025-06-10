import XCTest
@testable import XcresultParser

final class ExtensionsTests: XCTestCase {
    
    func testCoverageDataExtensions() {
        // Create test data
        let unitOverall = OverallCoverage(
            lineCoverage: 0.8,
            functionCoverage: 0.85,
            branchCoverage: nil,
            executableLines: 100,
            coveredLines: 80,
            executableFunctions: 20,
            coveredFunctions: 17
        )
        
        let uiOverall = OverallCoverage(
            lineCoverage: 0.9,
            functionCoverage: 0.95,
            branchCoverage: nil,
            executableLines: 100,
            coveredLines: 90,
            executableFunctions: 20,
            coveredFunctions: 19
        )
        
        let result = ParsedXCResult(
            overallCoverage: unitOverall,
            unitTestCoverage: unitOverall,
            uiTestCoverage: uiOverall,
            testSuites: [],
            attachments: [],
            tags: [],
            metadata: ParsedXCResult.Metadata(
                xcresultPath: "/test/path.xcresult",
                parseDate: Date(),
                xcodeVersion: "15.0"
            )
        )
        
        // Test coverage delta
        let delta = result.coverageDelta
        XCTAssertNotNil(delta)
        XCTAssertEqual(delta!.lineCoverage, 0.1, accuracy: 0.001)
        XCTAssertEqual(delta!.functionCoverage, 0.1, accuracy: 0.001)
        
        // Test coverage summary
        let summary = result.coverageSummary
        XCTAssertTrue(summary.contains("80.00%"))
    }
    
    func testTestDataExtensions() {
        // Create test data
        let testCase1 = TestCase(
            name: "test1",
            identifier: "test1",
            duration: 1.0,
            status: .passed,
            tags: ["smoke"],
            attachments: [],
            failureMessage: nil
        )
        
        let testCase2 = TestCase(
            name: "test2",
            identifier: "test2",
            duration: 5.0,
            status: .failed,
            tags: ["integration"],
            attachments: [],
            failureMessage: "Test failed"
        )
        
        let unitTestSuite = TestSuite(
            name: "UnitTests",
            tests: [testCase1],
            duration: 1.0,
            testType: .unit
        )
        
        let uiTestSuite = TestSuite(
            name: "UITests",
            tests: [testCase2],
            duration: 5.0,
            testType: .ui
        )
        
        let result = ParsedXCResult(
            overallCoverage: nil,
            unitTestCoverage: nil,
            uiTestCoverage: nil,
            testSuites: [unitTestSuite, uiTestSuite],
            attachments: [],
            tags: [],
            metadata: ParsedXCResult.Metadata(
                xcresultPath: "/test/path.xcresult",
                parseDate: Date(),
                xcodeVersion: "15.0"
            )
        )
        
        // Test suite filtering
        let unitSuites = result.testSuites(ofType: .unit)
        XCTAssertEqual(unitSuites.count, 1)
        XCTAssertEqual(unitSuites.first?.name, "UnitTests")
        
        // Test slowest tests
        let slowest = result.slowestTests(count: 1)
        XCTAssertEqual(slowest.count, 1)
        XCTAssertEqual(slowest.first?.name, "test2")
        
        // Test status filtering
        let failedTests = result.tests(withStatus: .failed)
        XCTAssertEqual(failedTests.count, 1)
        XCTAssertEqual(failedTests.first?.name, "test2")
        
        // Test duration calculations
        XCTAssertEqual(result.totalDuration, 6.0)
        XCTAssertEqual(result.averageTestDuration, 3.0)
    }
    
    func testAttachmentExtensions() {
        let screenshotData = "screenshot".data(using: .utf8)!
        let logData = "log content".data(using: .utf8)!
        
        let screenshot = TestAttachment(
            name: "screenshot",
            filename: "screen.png",
            uniformTypeIdentifier: "public.png",
            timestamp: Date(),
            data: screenshotData,
            testIdentifier: "test1",
            activityTitle: "Take Screenshot"
        )
        
        let log = TestAttachment(
            name: "log",
            filename: "test.log",
            uniformTypeIdentifier: "public.text",
            timestamp: Date(),
            data: logData,
            testIdentifier: "test2",
            activityTitle: "Save Log"
        )
        
        let attachments = [screenshot, log]
        
        // Test grouping by type
        let grouped = attachments.groupedByType
        XCTAssertEqual(grouped.keys.count, 2)
        XCTAssertTrue(grouped.keys.contains("public.png"))
        XCTAssertTrue(grouped.keys.contains("public.text"))
        
        // Test screenshots filtering
        let screenshots = attachments.screenshots
        XCTAssertEqual(screenshots.count, 1)
        XCTAssertEqual(screenshots.first?.name, "screenshot")
        
        // Test logs filtering
        let logs = attachments.logs
        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs.first?.name, "log")
        
        // Test total size
        let expectedSize = screenshotData.count + logData.count
        XCTAssertEqual(attachments.totalSize, expectedSize)
    }
    
    func testParsedXCResultExtensions() {
        // Create test result
        let overallCoverage = OverallCoverage(
            lineCoverage: 0.85,
            functionCoverage: 0.9,
            branchCoverage: nil,
            executableLines: 100,
            coveredLines: 85,
            executableFunctions: 20,
            coveredFunctions: 18
        )
        
        let passedTest = TestCase(
            name: "testPassed",
            identifier: "test1",
            duration: 1.0,
            status: .passed,
            tags: ["smoke"],
            attachments: [],
            failureMessage: nil
        )
        
        let failedTest = TestCase(
            name: "testFailed",
            identifier: "test2",
            duration: 2.0,
            status: .failed,
            tags: ["integration"],
            attachments: [],
            failureMessage: "Failed"
        )
        
        let testSuite = TestSuite(
            name: "TestSuite",
            tests: [passedTest, failedTest],
            duration: 3.0,
            testType: .unit
        )
        
        let attachment = TestAttachment(
            name: "attachment",
            filename: "file.txt",
            uniformTypeIdentifier: "public.text",
            timestamp: Date(),
            data: Data(),
            testIdentifier: "test2",
            activityTitle: nil
        )
        
        let result = ParsedXCResult(
            overallCoverage: overallCoverage,
            unitTestCoverage: overallCoverage,
            uiTestCoverage: nil,
            testSuites: [testSuite],
            attachments: [attachment],
            tags: [],
            metadata: ParsedXCResult.Metadata(
                xcresultPath: "/path/to/result.xcresult",
                parseDate: Date(),
                xcodeVersion: "14.0"
            )
        )
        
        // Test coverage summary
        let coverageSummary = result.coverageSummary
        XCTAssertTrue(coverageSummary.contains("85.00%"))
        XCTAssertTrue(coverageSummary.contains("90.00%"))
        
        // Test test summary
        let testSummary = result.testSummary
        XCTAssertTrue(testSummary.contains("Total Tests: 2"))
        XCTAssertTrue(testSummary.contains("Passed: 1"))
        XCTAssertTrue(testSummary.contains("Failed: 1"))
        
        // Test failed tests
        let failedTests = result.failedTests
        XCTAssertEqual(failedTests.count, 1)
        XCTAssertEqual(failedTests.first?.name, "testFailed")
        
        // Test tests with tag
        let smokeTests = result.tests(withTag: "smoke")
        XCTAssertEqual(smokeTests.count, 1)
        XCTAssertEqual(smokeTests.first?.name, "testPassed")
        
        // Test attachments for test
        let testAttachments = result.attachments(forTest: "test2")
        XCTAssertEqual(testAttachments.count, 1)
        XCTAssertEqual(testAttachments.first?.name, "attachment")
    }
}
        
        // Test coverage delta
        let delta = coverageData.coverageDelta
        XCTAssertEqual(delta.lineCoverage, 0.1, accuracy: 0.001)
        XCTAssertEqual(delta.functionCoverage, 0.1, accuracy: 0.001)
        
        // Test low coverage files
        let lowCoverageFiles = coverageData.filesWithLowCoverage(threshold: 0.7)
        XCTAssertEqual(lowCoverageFiles.count, 1)
        XCTAssertEqual(lowCoverageFiles.first?.name, "file1.swift")
        
        // Test top covered files
        let topFiles = coverageData.topCoveredFiles(count: 1)
        XCTAssertEqual(topFiles.count, 1)
        XCTAssertEqual(topFiles.first?.name, "file2.swift")
    }
    
    func testTestDataExtensions() {
        // Create test data
        let testCase1 = TestCase(
            name: "test1",
            identifier: "test1",
            duration: 1.0,
            status: .passed,
            tags: ["smoke"],
            attachments: [],
            failureMessage: nil
        )
        
        let testCase2 = TestCase(
            name: "test2",
            identifier: "test2",
            duration: 5.0,
            status: .failed,
            tags: ["integration"],
            attachments: [],
            failureMessage: "Test failed"
        )
        
        let unitTestSuite = TestSuite(
            name: "UnitTests",
            tests: [testCase1],
            duration: 1.0,
            testType: .unit
        )
        
        let uiTestSuite = TestSuite(
            name: "UITests",
            tests: [testCase2],
            duration: 5.0,
            testType: .ui
        )
        
        let testData = TestData(
            testSuites: [unitTestSuite, uiTestSuite],
            tags: []
        )
        
        // Test suite filtering
        let unitSuites = testData.testSuites(ofType: .unit)
        XCTAssertEqual(unitSuites.count, 1)
        XCTAssertEqual(unitSuites.first?.name, "UnitTests")
        
        // Test slowest tests
        let slowest = testData.slowestTests(count: 1)
        XCTAssertEqual(slowest.count, 1)
        XCTAssertEqual(slowest.first?.name, "test2")
        
        // Test status filtering
        let failedTests = testData.tests(withStatus: .failed)
        XCTAssertEqual(failedTests.count, 1)
        XCTAssertEqual(failedTests.first?.name, "test2")
        
        // Test duration calculations
        XCTAssertEqual(testData.totalDuration, 6.0)
        XCTAssertEqual(testData.averageTestDuration, 3.0)
    }
    
    func testAttachmentExtensions() {
        let screenshotData = "screenshot".data(using: .utf8)!
        let logData = "log content".data(using: .utf8)!
        
        let screenshot = TestAttachment(
            name: "screenshot",
            filename: "screen.png",
            uniformTypeIdentifier: "public.png",
            timestamp: Date(),
            data: screenshotData,
            testIdentifier: "test1",
            activityTitle: "Take Screenshot"
        )
        
        let log = TestAttachment(
            name: "log",
            filename: "test.log",
            uniformTypeIdentifier: "public.text",
            timestamp: Date(),
            data: logData,
            testIdentifier: "test2",
            activityTitle: "Save Log"
        )
        
        let attachments = [screenshot, log]
        
        // Test grouping by type
        let grouped = attachments.groupedByType
        XCTAssertEqual(grouped.keys.count, 2)
        XCTAssertTrue(grouped.keys.contains("public.png"))
        XCTAssertTrue(grouped.keys.contains("public.text"))
        
        // Test screenshots filtering
        let screenshots = attachments.screenshots
        XCTAssertEqual(screenshots.count, 1)
        XCTAssertEqual(screenshots.first?.name, "screenshot")
        
        // Test logs filtering
        let logs = attachments.logs
        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs.first?.name, "log")
        
        // Test total size
        let expectedSize = screenshotData.count + logData.count
        XCTAssertEqual(attachments.totalSize, expectedSize)
    }
    
    func testParsedXCResultExtensions() {
        // Create test result
        let overallCoverage = OverallCoverage(
            lineCoverage: 0.85,
            functionCoverage: 0.9,
            branchCoverage: nil,
            executableLines: 100,
            coveredLines: 85,
            executableFunctions: 20,
            coveredFunctions: 18
        )
        
        let coverage = CoverageData(
            overall: overallCoverage,
            targets: [],
            files: [],
            unitTestCoverage: TestTypeCoverage(overall: overallCoverage, targets: []),
            uiTestCoverage: TestTypeCoverage(overall: overallCoverage, targets: [])
        )
        
        let passedTest = TestCase(
            name: "testPassed",
            identifier: "test1",
            duration: 1.0,
            status: .passed,
            tags: ["smoke"],
            attachments: [],
            failureMessage: nil
        )
        
        let failedTest = TestCase(
            name: "testFailed",
            identifier: "test2",
            duration: 2.0,
            status: .failed,
            tags: ["integration"],
            attachments: [],
            failureMessage: "Failed"
        )
        
        let testSuite = TestSuite(
            name: "TestSuite",
            tests: [passedTest, failedTest],
            duration: 3.0,
            testType: .unit
        )
        
        let testData = TestData(testSuites: [testSuite], tags: [])
        
        let attachment = TestAttachment(
            name: "attachment",
            filename: "file.txt",
            uniformTypeIdentifier: "public.text",
            timestamp: Date(),
            data: Data(),
            testIdentifier: "test2",
            activityTitle: nil
        )
        
        let metadata = XCResultMetadata(
            xcresultPath: "/path/to/result.xcresult",
            parseDate: Date(),
            xcodeVersion: "14.0"
        )
        
        let result = ParsedXCResult(
            coverage: coverage,
            attachments: [attachment],
            testData: testData,
            metadata: metadata
        )
        
        // Test coverage summary
        let coverageSummary = result.coverageSummary
        XCTAssertTrue(coverageSummary.contains("85.00%"))
        XCTAssertTrue(coverageSummary.contains("90.00%"))
        
        // Test test summary
        let testSummary = result.testSummary
        XCTAssertTrue(testSummary.contains("Total Tests: 2"))
        XCTAssertTrue(testSummary.contains("Passed: 1"))
        XCTAssertTrue(testSummary.contains("Failed: 1"))
        
        // Test failed tests
        let failedTests = result.failedTests
        XCTAssertEqual(failedTests.count, 1)
        XCTAssertEqual(failedTests.first?.name, "testFailed")
        
        // Test tests with tag
        let smokeTests = result.tests(withTag: "smoke")
        XCTAssertEqual(smokeTests.count, 1)
        XCTAssertEqual(smokeTests.first?.name, "testPassed")
        
        // Test attachments for test
        let testAttachments = result.attachments(forTest: "test2")
        XCTAssertEqual(testAttachments.count, 1)
        XCTAssertEqual(testAttachments.first?.name, "attachment")
    }
}
