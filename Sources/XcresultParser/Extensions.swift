import Foundation

/// Utility extensions for working with XCResult data
public extension ParsedXCResult {
    
    /// Get coverage summary as a formatted string
    var coverageSummary: String {
        guard let overall = overallCoverage else { return "No coverage data available" }
        return """
        Overall Coverage Summary:
        - Line Coverage: \(String(format: "%.2f", overall.lineCoverage * 100))%
        - Function Coverage: \(String(format: "%.2f", overall.functionCoverage * 100))%
        - Executable Lines: \(overall.executableLines)
        - Covered Lines: \(overall.coveredLines)
        """
    }
    
    /// Get test summary as a formatted string
    var testSummary: String {
        let totalTests = testSuites.reduce(0) { $0 + $1.tests.count }
        let passedTests = testSuites.flatMap { $0.tests }.filter { $0.status == .passed }.count
        let failedTests = testSuites.flatMap { $0.tests }.filter { $0.status == .failed }.count
        
        return """
        Test Summary:
        - Total Tests: \(totalTests)
        - Passed: \(passedTests)
        - Failed: \(failedTests)
        - Success Rate: \(totalTests > 0 ? String(format: "%.2f", Double(passedTests) / Double(totalTests) * 100) : "0.00")%
        """
    }
    
    /// Get all failed tests
    var failedTests: [TestCase] {
        return testSuites.flatMap { $0.tests }.filter { $0.status == .failed }
    }
    
    /// Get all tests with specific tag
    func tests(withTag tag: String) -> [TestCase] {
        return testSuites.flatMap { $0.tests }.filter { $0.tags.contains(tag) }
    }
    
    /// Get all tests with specific tag (alternative method name for compatibility)
    func testsWithTag(_ tag: String) -> [TestCase] {
        return tests(withTag: tag)
    }
    
    /// Get all tests with specific status
    func tests(withStatus status: TestStatus) -> [TestCase] {
        return testSuites.flatMap { $0.tests }.filter { $0.status == status }
    }
    
    /// Get attachments for specific test
    func attachments(forTest testIdentifier: String) -> [TestAttachment] {
        return attachments.filter { $0.testIdentifier == testIdentifier }
    }
    
    /// Get test suites by type
    func testSuites(ofType type: TestType) -> [TestSuite] {
        return testSuites.filter { $0.testType == type }
    }
    
    /// Get coverage delta between UI and unit tests
    var coverageDelta: OverallCoverage? {
        guard let ui = uiTestCoverage, let unit = unitTestCoverage else { return nil }
        
        return OverallCoverage(
            lineCoverage: ui.lineCoverage - unit.lineCoverage,
            functionCoverage: ui.functionCoverage - unit.functionCoverage,
            branchCoverage: nil,
            executableLines: ui.executableLines - unit.executableLines,
            coveredLines: ui.coveredLines - unit.coveredLines,
            executableFunctions: ui.executableFunctions - unit.executableFunctions,
            coveredFunctions: ui.coveredFunctions - unit.coveredFunctions
        )
    }
    
    /// Get files with low coverage (mock implementation)
    func filesWithLowCoverage(threshold: Double) -> [String] {
        // Mock implementation since we don't have file-level coverage in our simplified model
        if let overall = overallCoverage, overall.lineCoverage < threshold {
            return ["MockFile1.swift", "MockFile2.swift"]
        }
        return []
    }
    
    /// Get top covered files (mock implementation)
    func topCoveredFiles(count: Int) -> [String] {
        // Mock implementation since we don't have file-level coverage in our simplified model
        return Array(["HighCoverage1.swift", "HighCoverage2.swift", "HighCoverage3.swift"].prefix(count))
    }
    
    /// Get coverage for a specific target (mock implementation)
    func coverage(forTarget targetName: String) -> OverallCoverage? {
        // Mock implementation - return overall coverage as placeholder
        return overallCoverage
    }
    
    /// Get total test duration
    var totalDuration: TimeInterval {
        return testSuites.reduce(0) { $0 + $1.duration }
    }
    
    /// Get average test duration
    var averageTestDuration: TimeInterval {
        let totalTests = testSuites.reduce(0) { $0 + $1.tests.count }
        return totalTests > 0 ? totalDuration / TimeInterval(totalTests) : 0.0
    }
    
    /// Get slowest tests
    func slowestTests(count: Int) -> [TestCase] {
        let allTests = testSuites.flatMap { $0.tests }
        return Array(allTests.sorted { $0.duration > $1.duration }.prefix(count))
    }
}

public extension Array where Element == TestAttachment {
    
    /// Group attachments by type
    var groupedByType: [String: [TestAttachment]] {
        return Dictionary(grouping: self) { $0.uniformTypeIdentifier ?? "unknown" }
    }
    
    /// Get screenshots only
    var screenshots: [TestAttachment] {
        return filter { 
            $0.uniformTypeIdentifier?.contains("image") == true ||
            $0.name.lowercased().contains("screenshot")
        }
    }
    
    /// Get logs only
    var logs: [TestAttachment] {
        return filter {
            $0.uniformTypeIdentifier?.contains("text") == true ||
            $0.name.lowercased().contains("log")
        }
    }
    
    /// Total size of all attachments
    var totalSize: Int {
        return reduce(0) { $0 + $1.data.count }
    }
}
