global class updatehighestEducation implements Database.Batchable<sObject> {
	
	global Database.queryLocator start(Database.BatchableContext BC){
		string query = 'SELECT Id, Highest_Level_of_Education_at_Start__c, Person_being_served__r.Level_of_Education__c FROM Service_Assignment__c WHERE Person_being_served__r.Level_of_Education__c != null';
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Service_Assignment__c> scope){
		for(Service_Assignment__c s: scope){
			s.Highest_Level_of_Education_at_Start__c = s.Person_being_served__r.Level_of_Education__c;
		}
		
		update scope;
		
	}
	
	global void finish(Database.BatchableContext BC){
		
		List<String> toAddresses = new List<String>();
		toAddresses.add('adam.vernatter@thementornetwork.com');
		Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('Service Assignment Batch');
		mail.setSubject('Service Assignment Batch to update Level of Education is completed');
		mail.setUseSignature(false);
		string body = 'Batch processing is completed. I do not what to do next';
		mail.setplainTextBody(body);
		mail.setSaveAsActivity(false);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
		
	}

}