#!/usr/bin/env swift

// Example usage of the XcresultParser library
// This demonstrates how to use the library programmatically

import Foundation
import XcresultParser

// Example of creating sample data (since we don't have actual xcresult files yet)
func demonstrateParser() {
    print("XCResult Parser Example")
    print("=====================")
    
    // Create sample data to demonstrate the models
    let fileCoverage = FileCoverage(
        path: "Sources/MyApp/MyClass.swift",
        name: "MyClass.swift",
        linesCovered: 85,
        linesTotal: 100,
        percentage: 85.0,
        functions: []
    )
    
    let targetCoverage = TargetCoverage(
        name: "MyApp",
        linesCovered: 850,
        linesTotal: 1000,
        percentage: 85.0,
        files: [fileCoverage]
    )
    
    let overallCoverage = OverallCoverage(
        linesCovered: 850,
        linesTotal: 1000,
        percentage: 85.0,
        targets: [targetCoverage]
    )
    
    let testCase = TestCase(
        identifier: "test_example",
        name: "testExample",
        classname: "MyAppTests",
        duration: 0.5,
        status: .passed,
        failureMessage: nil,
        tags: [TestTag(name: "unit", source: .testName)]
    )
    
    let testSuite = TestSuite(
        name: "MyAppTests",
        tests: 1,
        failures: 0,
        duration: 0.5,
        testCases: [testCase]
    )
    
    let parsedResult = ParsedXCResult(
        overallCoverage: overallCoverage,
        unitTestCoverage: overallCoverage,
        uiTestCoverage: nil,
        testSuites: [testSuite],
        attachments: [],
        tags: [TestTag(name: "unit", source: .testName)]
    )
    
    // Demonstrate JSON export
    do {
        let jsonData = try JSONEncoder().encode(parsedResult)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
        print("\nJSON Export Sample:")
        print(String(jsonString.prefix(200)) + "...")
        
        // Demonstrate filtering
        let unitTests = parsedResult.filterTestCases { $0.tags.contains { $0.name == "unit" } }
        print("\nFiltered unit tests: \(unitTests.count)")
        
        // Demonstrate coverage analysis
        if let coverage = parsedResult.overallCoverage {
            print("\nCoverage Analysis:")
            print("Overall: \(String(format: "%.1f", coverage.percentage))%")
            print("Targets: \(coverage.targets.count)")
            print("Files: \(coverage.targets.flatMap { $0.files }.count)")
        }
        
    } catch {
        print("Error: \(error)")
    }
}

// Run the demonstration
demonstrateParser()
