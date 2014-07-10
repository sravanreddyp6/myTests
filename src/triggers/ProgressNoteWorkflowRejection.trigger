trigger ProgressNoteWorkflowRejection on Progress_Note__c (before update) {
    for (Progress_Note__c pn: Trigger.new) {
        if (Trigger.oldMap.get(pn.Id).Approval_Status__c == 'Pending' &&pn.Approval_Status__c == 'Needs Refinement') {
            pn.Signature_on_File__c = 'N';
        }
    }
}