global class Progressnote_updateComments_Batch implements Database.Batchable<sObject> {
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		string query = 'SELECT id,Approval_Comment__c,Approval_User__c,(SELECT ID, TargetObjectID,Comments,ActorId FROM ProcessSteps Order by SystemModstamp desc LIMIT 1 ) FROM Progress_Note__c WHERE Approval_Status__c IN(\'Needs Refinement\',\'Approved\') AND Admission__r.State__c = \'AZ\'';
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Progress_Note__c>scope ){
		Map<Id, Progress_Note__c> pnMap = new Map<id,Progress_Note__c>(scope);
		List<Progress_note__c> toUpdate = new List<Progress_note__c>();
		for(Progress_Note__c pn : scope){
	    List<ProcessInstanceHistory> history = pn.ProcessSteps;
	    if(history.size()>0){
	    	Progress_Note__c p = pnMap.get(history[0].TargetObjectId);
            p.Approval_comment__c = history[0].Comments;
            p.Approval_User__c = history[0].ActorId;
	    	
	    	}
		}
		update pnMap.Values();
	}
	
	global void finish(Database.BatchableContext BC){
		List<String> toAddresses = new List<String>();
		toAddresses.add('contractor.sravan.pinninti@thementornetwork.com');
		Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('Salesforce Batch to Update Approval Comments');
		mail.setSubject('Approval Comments Update Batch Run');
		mail.setUseSignature(false);
		string body = 'Approval Comments batch is completed';
		mail.setplainTextBody(body);
		mail.setSaveAsActivity(false);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
	}
}