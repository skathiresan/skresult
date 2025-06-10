import Foundation
import XCResultKit

/// Extracts test data and tags from XCResult files
class TestDataExtractor {
    
    func extractTestData(from invocationRecord: ActionsInvocationRecord, resultFile: XCResultFile) throws -> ([TestSuite], [TestTag]) {
        var testSuites: [TestSuite] = []
        var allTags: [TestTag] = []
        
        for action in invocationRecord.actions {
            if let testsRef = action.actionResult.testsRef,
               let testPlanRunSummaries = resultFile.getTestPlanRunSummaries(id: testsRef.id) {
                
                let (suites, tags) = try extractTestSuitesAndTags(from: testPlanRunSummaries, resultFile: resultFile)
                testSuites.append(contentsOf: suites)
                allTags.append(contentsOf: tags)
            }
        }
        
        return (testSuites, allTags)
    }
    
    private func extractTestSuitesAndTags(
        from testPlanRunSummaries: ActionTestPlanRunSummaries,
        resultFile: XCResultFile
    ) throws -> ([TestSuite], [TestTag]) {
        var testSuites: [TestSuite] = []
        var allTags: [TestTag] = []
        
        // Process each summary in the test plan
        for summary in testPlanRunSummaries.summaries {
            for testableSummary in summary.testableSummaries {
                let (suites, tags) = try processTestSuite(testableSummary, resultFile: resultFile)
                testSuites.append(contentsOf: suites)
                allTags.append(contentsOf: tags)
            }
        }
        
        return (testSuites, allTags)
    }
    
    private func processTestSuite(
        _ testableSummary: ActionTestableSummary,
        resultFile: XCResultFile
    ) throws -> ([TestSuite], [TestTag]) {
        var testSuites: [TestSuite] = []
        var allTags: [TestTag] = []
        
        // Process each test group in the testable summary
        for testGroup in testableSummary.tests {
            let (suite, tags) = try processTestGroup(testGroup, resultFile: resultFile, targetName: testableSummary.targetName)
            if let suite = suite {
                testSuites.append(suite)
            }
            allTags.append(contentsOf: tags)
        }
        
        return (testSuites, allTags)
    }
    
    private func processTestGroup(
        _ testGroup: ActionTestSummaryGroup,
        resultFile: XCResultFile,
        targetName: String?
    ) throws -> (TestSuite?, [TestTag]) {
        var testCases: [TestCase] = []
        var allTags: [TestTag] = []
        
        // Process individual tests in the group
        for test in testGroup.subtests {
            if let testSummary = test as? ActionTestSummary {
                let (testCase, tags) = try processTestCase(testSummary, resultFile: resultFile)
                if let testCase = testCase {
                    testCases.append(testCase)
                }
                allTags.append(contentsOf: tags)
            }
        }
        
        // Create test suite
        let testSuite = TestSuite(
            name: testGroup.name ?? "Unknown Test Group",
            tests: testCases,
            duration: testCases.reduce(0) { $0 + $1.duration },
            testType: .unit
        )
        
        return (testSuite, allTags)
    }
    
    private func processTestCase(
        _ testSummary: ActionTestSummary,
        resultFile: XCResultFile
    ) throws -> (TestCase?, [TestTag]) {
        var tags: [TestTag] = []
        
        // Extract tags from test name
        let testName = testSummary.name ?? "UnknownTest"
        let nameTags = extractTagsFromString(testName)
        tags.append(contentsOf: nameTags.map { TestTag(name: $0, testIdentifiers: [testName]) })
        
        // Extract tags from activities
        let activityTags = extractTagsFromActivities(testSummary.activitySummaries)
        tags.append(contentsOf: activityTags.map { TestTag(name: $0, testIdentifiers: [testName]) })
        
        // Determine test status
        let status = determineTestStatus(from: testSummary)
        
        // Get failure message if test failed
        let failureMessage = status == .failed ? extractFailureMessage(from: testSummary) : nil
        
        let testCase = TestCase(
            name: testName,
            identifier: testName,
            duration: testSummary.duration,
            status: status,
            tags: tags.map { $0.name },
            attachments: [], // We'll handle attachments separately
            failureMessage: failureMessage
        )
        
        return (testCase, tags)
    }
    
    private func determineTestStatus(from testSummary: ActionTestSummary) -> TestStatus {
        switch testSummary.testStatus.lowercased() {
        case "success":
            return .passed
        case "failure":
            return .failed
        default:
            return .skipped
        }
    }
    
    private func extractTagsFromActivities(_ activities: [ActionTestActivitySummary]) -> [String] {
        var tags: [String] = []
        
        for activity in activities {
            let activityTags = extractTagsFromString(activity.title)
            tags.append(contentsOf: activityTags)
            
            // Recursively extract from sub-activities
            if !activity.subactivities.isEmpty {
                let subTags = extractTagsFromActivities(activity.subactivities)
                tags.append(contentsOf: subTags)
            }
        }
        
        return tags
    }
    
    private func extractTagsFromString(_ text: String) -> [String] {
        var tags: [String] = []
        
        // Tag patterns to match
        let patterns = [
            #"@(\w+)"#,           // @tag
            #"#(\w+)"#,           // #tag
            #"\[(\w+)\]"#,        // [tag]
            #"tag:(\w+)"#         // tag:name
        ]
        
        for pattern in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
                
                for match in matches {
                    if match.numberOfRanges > 1 {
                        let range = match.range(at: 1)
                        if let swiftRange = Range(range, in: text) {
                            tags.append(String(text[swiftRange]))
                        }
                    }
                }
            } catch {
                // Continue with other patterns if regex fails
            }
        }
        
        return tags
    }
    
    private func extractClassName(from testName: String) -> String {
        // Extract class name from test method name (e.g., "MyClassTests/testExample" -> "MyClassTests")
        if let range = testName.range(of: "/") {
            return String(testName[..<range.lowerBound])
        }
        return testName
    }
    
    private func extractFailureMessage(from testSummary: ActionTestSummary) -> String? {
        // Look for failure information in the activity summaries
        for activity in testSummary.activitySummaries {
            if activity.title.contains("failed") || activity.title.contains("error") {
                return activity.title
            }
        }
        return nil
    }
}
