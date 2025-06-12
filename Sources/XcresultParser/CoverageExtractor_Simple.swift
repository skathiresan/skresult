import Foundation
import XCResultKit

/// Simplified coverage extractor that only returns real parsed data (no mock data)
class SimpleCoverageExtractor {
    
    func extractCoverage(from invocationRecord: ActionsInvocationRecord, resultFile: XCResultFile) throws -> (OverallCoverage?, OverallCoverage?, OverallCoverage?) {
        // Try to get actual coverage data using XCResultKit
        guard let codeCoverage = resultFile.getCodeCoverage() else {
            // If no coverage data is available, return nil (no fake data)
            return (nil, nil, nil)
        }
        
        let coverage = try processCoverageData(codeCoverage)
        
        // For now, we return the same coverage for all types since xccov gives us overall coverage
        // In a real implementation, you might need to parse separate xcresult files or use 
        // additional heuristics to separate unit vs UI test coverage
        let overallCoverage = coverage
        
        // Check if we have test actions to determine if this includes unit/UI test coverage
        let hasTestActions = invocationRecord.actions.contains { action in
            return action.actionResult.testsRef != nil
        }
        
        // Return coverage data for unit and UI tests only if we have test actions
        let unitTestCoverage = hasTestActions ? coverage : nil
        let uiTestCoverage = hasTestActions ? coverage : nil
        
        return (overallCoverage, unitTestCoverage, uiTestCoverage)
    }
    
    private func processCoverageData(_ codeCoverage: CodeCoverage) throws -> OverallCoverage {
        let totalExecutableLines = codeCoverage.executableLines
        let totalCoveredLines = codeCoverage.coveredLines
        var totalExecutableFunctions = 0
        var totalCoveredFunctions = 0
        
        // Process each target and file in the coverage data
        for target in codeCoverage.targets {
            for file in target.files {
                // Count functions
                for function in file.functions {
                    totalExecutableFunctions += 1
                    if function.executionCount > 0 {
                        totalCoveredFunctions += 1
                    }
                }
            }
        }
        
        let lineCoverage = codeCoverage.lineCoverage
        let functionCoverage = totalExecutableFunctions > 0 ? Double(totalCoveredFunctions) / Double(totalExecutableFunctions) : 0.0
        
        return OverallCoverage(
            lineCoverage: lineCoverage,
            functionCoverage: functionCoverage,
            branchCoverage: nil, // Branch coverage not readily available from XCResultKit
            executableLines: totalExecutableLines,
            coveredLines: totalCoveredLines,
            executableFunctions: totalExecutableFunctions,
            coveredFunctions: totalCoveredFunctions
        )
    }
}