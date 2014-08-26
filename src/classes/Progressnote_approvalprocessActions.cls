public class Progressnote_approvalprocessActions {

	@future
	
	public static void updateApprovaluser(string s){
		Map<id,Progress_Note__c> progMap = (Map<id,Progress_Note__c>) JSON.deserialize(s, Map<id,Progress_Note__c>.class);
		system.debug('restored Map '+progMap);
		List<ProcessInstance> processList =[SELECT Id, TargetObjectID, (SELECT Id, ActorId, processInstanceId FROM Workitems Order by Systemmodstamp desc LIMIT 1) FROM ProcessInstance WHERE TargetObjectID IN:progMap.keyset()];
		List<Progress_Note__c> tobeupdated = new List<Progress_Note__c>();
    	for(ProcessInstance p : processList){
    			if(progMap.containsKey(p.TargetObjectId)){
    				List<ProcessInstanceworkItem> items = p.workItems;
    				if(items.size()>0){
    				Progress_Note__c pn = progMap.get(p.TargetObjectId);
    				if(pn.Approval_User__c != items[0].ActorId){
						pn.Approval_User__c = items[0].ActorId;
						tobeUpdated.add(pn);
						}
    				}
    			}
    			
    	}
		
		update tobeUpdated;
		
	}

}