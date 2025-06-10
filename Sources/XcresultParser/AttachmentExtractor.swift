import Foundation
import XCResultKit

/// Extracts attachments from XCResult files
class AttachmentExtractor {
    
    func extractAttachments(from invocationRecord: ActionsInvocationRecord, resultFile: XCResultFile) throws -> [TestAttachment] {
        var attachments: [TestAttachment] = []
        
        for action in invocationRecord.actions {
            if let testsRef = action.actionResult.testsRef,
               let testPlanRunSummaries = resultFile.getTestPlanRunSummaries(id: testsRef.id) {
                
                let actionAttachments = try extractAttachmentsFromTestPlan(testPlanRunSummaries, resultFile: resultFile)
                attachments.append(contentsOf: actionAttachments)
            }
        }
        
        return attachments
    }
    
    private func extractAttachmentsFromTestPlan(
        _ testPlanRunSummaries: ActionTestPlanRunSummaries,
        resultFile: XCResultFile
    ) throws -> [TestAttachment] {
        var attachments: [TestAttachment] = []
        
        for summary in testPlanRunSummaries.summaries {
            for testableSummary in summary.testableSummaries {
                let testAttachments = try extractAttachmentsFromTestable(testableSummary, resultFile: resultFile)
                attachments.append(contentsOf: testAttachments)
            }
        }
        
        return attachments
    }
    
    private func extractAttachmentsFromTestable(
        _ testableSummary: ActionTestableSummary,
        resultFile: XCResultFile
    ) throws -> [TestAttachment] {
        var attachments: [TestAttachment] = []
        
        for testGroup in testableSummary.tests {
            let groupAttachments = try extractAttachmentsFromTestGroup(testGroup, resultFile: resultFile)
            attachments.append(contentsOf: groupAttachments)
        }
        
        return attachments
    }
    
    private func extractAttachmentsFromTestGroup(
        _ testGroup: ActionTestSummaryGroup,
        resultFile: XCResultFile
    ) throws -> [TestAttachment] {
        var attachments: [TestAttachment] = []
        
        for test in testGroup.subtests {
            if let testSummary = test as? ActionTestSummary {
                let testAttachments = try extractAttachmentsFromTest(testSummary, resultFile: resultFile)
                attachments.append(contentsOf: testAttachments)
            }
        }
        
        return attachments
    }
    
    private func extractAttachmentsFromTest(
        _ testSummary: ActionTestSummary,
        resultFile: XCResultFile
    ) throws -> [TestAttachment] {
        var attachments: [TestAttachment] = []
        
        // Extract attachments from activities
        for activity in testSummary.activitySummaries {
            let activityAttachments = try extractAttachmentsFromActivity(
                activity,
                resultFile: resultFile,
                testIdentifier: testSummary.name ?? "UnknownTest"
            )
            attachments.append(contentsOf: activityAttachments)
        }
        
        return attachments
    }
    
    private func extractAttachmentsFromActivity(
        _ activity: ActionTestActivitySummary,
        resultFile: XCResultFile,
        testIdentifier: String
    ) throws -> [TestAttachment] {
        var attachments: [TestAttachment] = []
        
        // Extract attachments from current activity
        for attachment in activity.attachments {
            if let testAttachment = try createTestAttachment(
                from: attachment,
                resultFile: resultFile,
                testIdentifier: testIdentifier,
                activityTitle: activity.title
            ) {
                attachments.append(testAttachment)
            }
        }
        
        // Recursively extract from sub-activities
        for subActivity in activity.subactivities {
            let subAttachments = try extractAttachmentsFromActivity(
                subActivity,
                resultFile: resultFile,
                testIdentifier: testIdentifier
            )
            attachments.append(contentsOf: subAttachments)
        }
        
        return attachments
    }
    
    private func createTestAttachment(
        from attachment: ActionTestAttachment,
        resultFile: XCResultFile,
        testIdentifier: String,
        activityTitle: String?
    ) throws -> TestAttachment? {
        
        // Get attachment data
        var attachmentData = Data()
        if let payloadRef = attachment.payloadRef {
            attachmentData = resultFile.getPayload(id: payloadRef.id) ?? Data()
        }
        
        return TestAttachment(
            name: attachment.name ?? "Unknown",
            filename: attachment.filename,
            uniformTypeIdentifier: attachment.uniformTypeIdentifier,
            timestamp: attachment.timestamp,
            data: attachmentData,
            testIdentifier: testIdentifier,
            activityTitle: activityTitle
        )
    }
}
