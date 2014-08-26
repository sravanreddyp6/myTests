trigger ProgressNoteWorkflowRejection on Progress_Note__c (before update) {
	if(!system.isFuture() && !system.isBatch()){
		Map<Id, Progress_Note__c> pnMap = new Map<id, Progress_Note__c>();
		Map<Id,Progress_Note__c> pendingpnMap = new Map<id,Progress_Note__c>();
		Map<id,id> processinstanceIds = new Map<id,id>();
	    for (Progress_Note__c pn: Trigger.new) {
	        if (Trigger.oldMap.get(pn.Id).Approval_Status__c == 'Pending' &&pn.Approval_Status__c == 'Needs Refinement') {
	            pn.Signature_on_File__c = 'N';
	        }
	        if(Trigger.oldMap.get(pn.Id).Approval_Status__c != pn.Approval_Status__c & pn.Approval_Status__c != 'Pending'){
	            pnMap.put(pn.Id, pn);
	        }
	        if(Trigger.oldMap.get(pn.Id).Approval_Status__c != pn.Approval_Status__c & pn.Approval_Status__c == 'Pending'){
	            pendingpnMap.put(pn.Id, pn);
	        }
	    }
	    
	 //Added by Sravan to copy Approval comments from approval process to Approval_Comment__c field on Progress Notes EB-186,08/08/2014   
	    if(pnMap.size()>0){
		    List<Progress_Note__c> notes = [SELECT id,Approval_Comment__c,Approval_User__c,(SELECT ID, TargetObjectID,Comments,ActorId,ProcessInstanceId FROM ProcessSteps Order by SystemModstamp desc LIMIT 1 ) FROM Progress_Note__c WHERE ID IN: pnMap.KeySet()];
		    		for(Progress_Note__c n : notes){
		    			List<ProcessInstanceHistory> history = n.ProcessSteps;
		    			if(history.size()>0){
			    			Progress_Note__c p = pnMap.get(history[0].TargetObjectId);
			    			p.Approval_comment__c = history[0].Comments;
			    			p.Approval_User__c = history[0].ActorId;
			    			//processinstanceIds.put(history[0].ProcessInstanceId,history[0].TargetObjectID);
		    			}
		    			
		    		}
		    	}
		//This logic is to copy the name of the user who is assigned to the approval process during pending Status. This has to be handled asynchronously as the workflow
		//field update fires even before the approval user is selected by the initial submitter.   Sravan - 08/19/2014 2:02 PM.	
		if(pendingpnMap.size()>0){
	    	String serialized = JSON.serialize(pendingpnMap); //Serializing the Map as sObjects cannot be passed as arguments in @future methods 
	    	Progressnote_approvalprocessActions.updateApprovaluser(serialized);
		    }
	  
    }
}