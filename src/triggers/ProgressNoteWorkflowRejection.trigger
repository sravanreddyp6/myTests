trigger ProgressNoteWorkflowRejection on Progress_Note__c (before update) {
	Map<Id, Progress_Note__c> pnMap = new Map<id, Progress_Note__c>();
    for (Progress_Note__c pn: Trigger.new) {
        if (Trigger.oldMap.get(pn.Id).Approval_Status__c == 'Pending' &&pn.Approval_Status__c == 'Needs Refinement') {
            pn.Signature_on_File__c = 'N';
        }
        if (Trigger.oldMap.get(pn.Id).Approval_Status__c == 'Pending' &&(pn.Approval_Status__c == 'Needs Refinement' || pn.Approval_Status__c == 'Approved')) {
            pnMap.put(pn.Id, pn);
        }
    }
    
 //Added by Sravan to copy Approval comments from approval procss to Approval_Comment__c field on Progress Notes EB-186,08/08/2014   
    List<Progress_Note__c> notes = [SELECT id,Approval_Comment__c,(SELECT ID, TargetObjectID,Comments FROM ProcessSteps Order by SystemModstamp desc LIMIT 1 ) FROM Progress_Note__c WHERE ID IN: pnMap.KeySet()];
    	if(notes.size()>0){
    		for(Progress_Note__c n : notes){
    			List<ProcessInstanceHistory> history = n.ProcessSteps;
    			Progress_Note__c p = pnMap.get(history[0].TargetObjectId);
    			p.Approval_comment__c = history[0].Comments;
    			
    		}
    		
    	/*for(ProcessInstanceHistory h : notes[0].ProcessSteps){
    		Progress_Note__c p = pnMap.get(h.TargetObjectId);
    		p.Approval_Comment__c = h.Comments;
    	}*/
    	
    }
    	
}