global class Progressnote_updateApproval_user implements Database.Batchable<sObject>{
	global final string Query;
	
	global Progressnote_updateApproval_user (String q){
		Query = q;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(Query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		ProcessInstanceStep [] steps = (ProcessInstanceStep[])scope;
		set<Id> ids = new set<id>();
		for(ProcessInstanceStep s: steps){
			if(string.valueof(s.ProcessInstance.TargetObjectId).startswith('a0L')){
				ids.add(s.ProcessInstance.TargetObjectId);
			}
		}
		
		Map<Id,Progress_Note__c> reassignedNotes = new Map<Id, Progress_note__c>([SELECT Id,Approval_User__c, Approval_Status__c FROM Progress_Note__c WHERE Id IN:ids]);
		List<Progress_Note__c> tobeUpdated = new List<Progress_Note__c>();
		List<ProcessInstance> processList = [SELECT ID,TargetObjectId,(SELECT Id, ActorID,ProcessInstanceId FROM WorkItems order by Systemmodstamp desc LIMIT 1) FROM ProcessInstance WHERE TargetObjectID IN:reassignedNotes.keySet()];
		for(ProcessInstance p :processList){
			if(reassignedNotes.containskey(p.TargetObjectId)){
				List<ProcessInstanceworkItem> items = p.workItems;
				if(items.size()>0){
					Progress_Note__c pn = reassignedNotes.get(p.TargetObjectId);
					if(pn.Approval_User__c != items[0].ActorId){
						pn.Approval_User__c = items[0].ActorId;
						tobeUpdated.add(pn);
					}
				}
			}
		}
		
		if(tobeUpdated.size()>0){
			try{
				update tobeUpdated;
			}
			
			catch (dmlException e){
				system.debug(e);
			}
			
		}
		
	}
	
	global void finish(Database.BatchableContext BC){
		List<String> toAddresses = new List<String>();
		toAddresses.add('contractor.sravan.pinninti@thementornetwork.com');
		Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('Salesforce Batch to Update Approval User Run');
		mail.setSubject('Approval User Update Batch Run');
		mail.setUseSignature(false);
		string body = 'Your batch is completed';
		mail.setplainTextBody(body);
		mail.setSaveAsActivity(false);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
		
	}

}