import Foundation
import XCResultKit

/// Extensions to work with XCResultKit types
extension XCResultFile {
    func getCodeCoverage() -> CodeCoverage? {
        guard let invocationRecord = getInvocationRecord() else {
            return nil
        }
        
        // Look for coverage in the actions
        for action in invocationRecord.actions {
            if let buildResult = action.buildResult,
               let _ = buildResult.logRef {
                // For now, return a basic CodeCoverage object
                // In a real implementation, we would parse the log data
                return CodeCoverage()
            }
        }
        return nil
    }
}

extension ActionsInvocationRecord {
    var xcodeVersion: String? {
        // The metadata property might not exist in this version
        // Return a placeholder for now
        return "Unknown"
    }
}

extension ActionRecord {
    var buildResult: ActionResult? {
        return actionResult
    }
}
