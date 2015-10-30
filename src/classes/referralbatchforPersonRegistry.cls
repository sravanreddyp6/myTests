global class referralbatchforPersonRegistry implements Database.Batchable<sObject> {
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		string query = 'SELECT Id, Legal_Guardian_Status__c, Guardianship_Type__c FROM Referral__c WHERE Legal_Guardian_Status__c =\'Self\'';
		
		return  Database.getQueryLocator(query);
		
	}
	
	global void execute(Database.BatchableContext BC, List<Referral__c> scope){
		List<Referral__c> guardianshipUpdateList = new List<Referral__c>();
		for(Referral__c ref: scope){
			ref.Guardianship_Type__c = 'Self';
			guardianshipUpdateList.add(ref);
		}
		
		if(guardianshipUpdateList.size() > 0){
			update guardianshipUpdateList;
		}
		
	}
	
	global void finish(Database.BatchableContext BC){
		List<String> toAddresses = new List<String>{'adam.vernatter@thementornetwork.com', 'dylan.melnik@thementornetwork.com'};
		//toAddresses.add('adam.vernatter@thementornetwork.com');
		Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('referralbatchforPersonRegistry');
		mail.setSubject('referralbatchforPersonRegistry is completed.');
		mail.setUseSignature(false);
		string body = 'Batch processing is completed. In production, delete me after you get this message.';
		mail.setplainTextBody(body);
		mail.setSaveAsActivity(false);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
		
	}

}