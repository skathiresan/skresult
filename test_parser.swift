#!/usr/bin/env swift

import Foundation

// This is a simple test script to demonstrate the parser functionality
// Since we don't have actual xcresult files, we'll create a mock one for testing

let testPath = "/tmp/mock.xcresult"

print("=== XcresultParser Test ===")
print("Testing with mock xcresult path: \(testPath)")

// This would fail since the path doesn't exist, but shows the expected usage
print("\nExpected usage:")
print("""
import XcresultParser

let parser = XcresultParser()
let result = try parser.parse(xcresultPath: "\(testPath)")

print("Overall Coverage: \\(result.overallCoverage?.percentage ?? 0)%")
print("Unit Test Coverage: \\(result.unitTestCoverage?.percentage ?? 0)%")
print("UI Test Coverage: \\(result.uiTestCoverage?.percentage ?? 0)%")
print("Test Suites: \\(result.testSuites.count)")
print("Attachments: \\(result.attachments.count)")
print("Tags: \\(result.tags.count)")
""")

print("\nTo test with real xcresult files:")
print("1. Run your iOS/macOS project tests in Xcode")
print("2. Find the generated .xcresult bundle (usually in DerivedData)")
print("3. Use the CLI: swift run xcresult-cli parse /path/to/your.xcresult")
print("4. Or use the API in your Swift code")
