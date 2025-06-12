import Foundation

/// Container for all parsed XCResult data
public struct ParsedXCResult: Codable {
    public let overallCoverage: OverallCoverage?
    public let unitTestCoverage: OverallCoverage?
    public let uiTestCoverage: OverallCoverage?
    public let testSuites: [TestSuite]
    public let attachments: [TestAttachment]
    public let tags: [TestTag]
    public let metadata: Metadata
    
    public init(
        overallCoverage: OverallCoverage?,
        unitTestCoverage: OverallCoverage?,
        uiTestCoverage: OverallCoverage?,
        testSuites: [TestSuite],
        attachments: [TestAttachment],
        tags: [TestTag],
        metadata: Metadata
    ) {
        self.overallCoverage = overallCoverage
        self.unitTestCoverage = unitTestCoverage
        self.uiTestCoverage = uiTestCoverage
        self.testSuites = testSuites
        self.attachments = attachments
        self.tags = tags
        self.metadata = metadata
    }
    
    public struct Metadata: Codable {
        public let xcresultPath: String
        public let parseDate: Date
        public let xcodeVersion: String?
        
        public init(xcresultPath: String, parseDate: Date, xcodeVersion: String?) {
            self.xcresultPath = xcresultPath
            self.parseDate = parseDate
            self.xcodeVersion = xcodeVersion
        }
    }
    
    // Convenience properties for backwards compatibility with Examples
    public var coverage: ParsedXCResult { return self }
    public var testData: ParsedXCResult { return self }
    
    // Properties for file-level and target-level coverage (empty by default since we don't parse file-level coverage yet)
    public var overall: OverallCoverage? { return overallCoverage }
    public var files: [FileCoverage] { 
        // Return empty array since file-level coverage parsing is not implemented yet
        return []
    }
    public var targets: [TargetCoverage] {
        // Return empty array since target-level coverage parsing is not implemented yet
        return []
    }
}

/// Overall coverage metrics
public struct OverallCoverage: Codable {
    public let lineCoverage: Double
    public let functionCoverage: Double
    public let branchCoverage: Double?
    public let executableLines: Int
    public let coveredLines: Int
    public let executableFunctions: Int
    public let coveredFunctions: Int
    
    public init(lineCoverage: Double, functionCoverage: Double, branchCoverage: Double?, executableLines: Int, coveredLines: Int, executableFunctions: Int, coveredFunctions: Int) {
        self.lineCoverage = lineCoverage
        self.functionCoverage = functionCoverage
        self.branchCoverage = branchCoverage
        self.executableLines = executableLines
        self.coveredLines = coveredLines
        self.executableFunctions = executableFunctions
        self.coveredFunctions = coveredFunctions
    }
    
    // Convenience properties for Examples.swift compatibility
    public var percentage: Double { return lineCoverage * 100 }
    public var linesCovered: Int { return coveredLines }
    public var linesTotal: Int { return executableLines }
    public var functionsCovered: Int { return coveredFunctions }
    public var functionsTotal: Int { return executableFunctions }
    public var targets: [TargetCoverage] { return [] } // Mock for now
}

/// Target-level coverage
public struct TargetCoverage: Codable {
    public let name: String
    public let lineCoverage: Double
    public let functionCoverage: Double
    public let branchCoverage: Double?
    public let executableLines: Int
    public let coveredLines: Int
    public let files: [FileCoverage]
    
    public init(name: String, lineCoverage: Double, functionCoverage: Double, branchCoverage: Double?, executableLines: Int, coveredLines: Int, files: [FileCoverage]) {
        self.name = name
        self.lineCoverage = lineCoverage
        self.functionCoverage = functionCoverage
        self.branchCoverage = branchCoverage
        self.executableLines = executableLines
        self.coveredLines = coveredLines
        self.files = files
    }
    
    // Convenience properties for Examples.swift compatibility
    public var percentage: Double { return lineCoverage * 100 }
}

/// File-level coverage
public struct FileCoverage: Codable {
    public let path: String
    public let name: String
    public let lineCoverage: Double
    public let functionCoverage: Double
    public let branchCoverage: Double?
    public let executableLines: Int
    public let coveredLines: Int
    public let functions: [FunctionCoverage]
    public let lineCoverageData: [LineCoverage]
    
    public init(path: String, name: String, lineCoverage: Double, functionCoverage: Double, branchCoverage: Double?, executableLines: Int, coveredLines: Int, functions: [FunctionCoverage], lineCoverageData: [LineCoverage]) {
        self.path = path
        self.name = name
        self.lineCoverage = lineCoverage
        self.functionCoverage = functionCoverage
        self.branchCoverage = branchCoverage
        self.executableLines = executableLines
        self.coveredLines = coveredLines
        self.functions = functions
        self.lineCoverageData = lineCoverageData
    }
    
    // Convenience properties for Examples.swift compatibility
    public var percentage: Double { return lineCoverage * 100 }
}

/// Function-level coverage
public struct FunctionCoverage: Codable {
    public let name: String
    public let lineCoverage: Double
    public let executionCount: Int
    public let lineNumber: Int
    
    public init(name: String, lineCoverage: Double, executionCount: Int, lineNumber: Int) {
        self.name = name
        self.lineCoverage = lineCoverage
        self.executionCount = executionCount
        self.lineNumber = lineNumber
    }
}

/// Line-level coverage data
public struct LineCoverage: Codable {
    public let lineNumber: Int
    public let executionCount: Int
    public let isExecutable: Bool
    
    public init(lineNumber: Int, executionCount: Int, isExecutable: Bool) {
        self.lineNumber = lineNumber
        self.executionCount = executionCount
        self.isExecutable = isExecutable
    }
}

/// Coverage data by test type
public struct TestTypeCoverage: Codable {
    public let overall: OverallCoverage
    public let targets: [TargetCoverage]
    
    public init(overall: OverallCoverage, targets: [TargetCoverage]) {
        self.overall = overall
        self.targets = targets
    }
}

/// Test attachment data
public struct TestAttachment: Codable {
    public let name: String
    public let filename: String?
    public let uniformTypeIdentifier: String?
    public let timestamp: Date?
    public let data: Data
    public let testIdentifier: String
    public let activityTitle: String?
    
    public init(name: String, filename: String?, uniformTypeIdentifier: String?, timestamp: Date?, data: Data, testIdentifier: String, activityTitle: String?) {
        self.name = name
        self.filename = filename
        self.uniformTypeIdentifier = uniformTypeIdentifier
        self.timestamp = timestamp
        self.data = data
        self.testIdentifier = testIdentifier
        self.activityTitle = activityTitle
    }
    
    // Convenience properties for Examples.swift compatibility
    public var type: AttachmentType {
        guard let uti = uniformTypeIdentifier else { return .data }
        if uti.contains("image") { return .screenshot }
        if uti.contains("log") || uti.contains("text") { return .log }
        return .data
    }
    public var sizeInBytes: Int { return data.count }
    public var testName: String? { return activityTitle }
}

/// Attachment type enumeration
public enum AttachmentType: Codable {
    case screenshot
    case log
    case data
}

/// Test suite information
public struct TestSuite: Codable {
    public let name: String
    public let tests: [TestCase]
    public let duration: TimeInterval
    public let testType: TestType
    
    public init(name: String, tests: [TestCase], duration: TimeInterval, testType: TestType) {
        self.name = name
        self.tests = tests
        self.duration = duration
        self.testType = testType
    }
    
    // Convenience properties for Examples.swift compatibility
    public var testCases: [TestCase] { return tests }
}

/// Individual test case
public struct TestCase: Codable {
    public let name: String
    public let identifier: String
    public let duration: TimeInterval
    public let status: TestStatus
    public let tags: [String]
    public let attachments: [TestAttachment]
    public let failureMessage: String?
    
    public init(name: String, identifier: String, duration: TimeInterval, status: TestStatus, tags: [String], attachments: [TestAttachment], failureMessage: String?) {
        self.name = name
        self.identifier = identifier
        self.duration = duration
        self.status = status
        self.tags = tags
        self.attachments = attachments
        self.failureMessage = failureMessage
    }
}

/// Test tag information
public struct TestTag: Codable {
    public let name: String
    public let testIdentifiers: [String]
    
    public init(name: String, testIdentifiers: [String]) {
        self.name = name
        self.testIdentifiers = testIdentifiers
    }
}

/// XCResult metadata
public struct XCResultMetadata {
    public let xcresultPath: String
    public let parseDate: Date
    public let xcodeVersion: String?
    
    public init(xcresultPath: String, parseDate: Date, xcodeVersion: String?) {
        self.xcresultPath = xcresultPath
        self.parseDate = parseDate
        self.xcodeVersion = xcodeVersion
    }
}

/// Test type enumeration
public enum TestType: Codable {
    case unit
    case ui
    case integration
    case performance
    case unknown
}

/// Test status enumeration
public enum TestStatus: Codable {
    case passed
    case failed
    case skipped
    case unknown
}
