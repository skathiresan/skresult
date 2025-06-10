import Foundation
@testable import XcresultParser

// Simple test without XCTest to verify the basic functionality works
func runBasicTests() {
    print("🧪 Running basic functionality tests...")
    
    // Test data model creation
    let coverage = OverallCoverage(
        lineCoverage: 0.8,
        functionCoverage: 0.85,
        branchCoverage: nil,
        executableLines: 100,
        coveredLines: 80,
        executableFunctions: 20,
        coveredFunctions: 17
    )
    
    assert(coverage.percentage == 80.0, "Coverage percentage calculation failed")
    assert(coverage.linesCovered == 80, "Lines covered property failed")
    assert(coverage.functionsTotal == 20, "Functions total property failed")
    
    // Test ParsedXCResult creation
    let result = ParsedXCResult(
        overallCoverage: coverage,
        unitTestCoverage: coverage,
        uiTestCoverage: nil,
        testSuites: [],
        attachments: [],
        tags: [],
        metadata: ParsedXCResult.Metadata(
            xcresultPath: "/test/path.xcresult",
            parseDate: Date(),
            xcodeVersion: "15.0"
        )
    )
    
    assert(result.totalDuration == 0.0, "Total duration calculation failed")
    assert(result.averageTestDuration == 0.0, "Average duration calculation failed")
    assert(result.testsWithTag("test").isEmpty, "Tests with tag filtering failed")
    
    print("✅ Basic functionality tests passed!")
}

// Run the tests
runBasicTests()
