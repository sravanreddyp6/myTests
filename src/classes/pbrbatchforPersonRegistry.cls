global class pbrbatchforPersonRegistry implements Database.Batchable<sObject>{
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		string query = 'SELECT Id, Gender__c FROM Person_Being_Referred__c WHERE (Gender__c =\'Transgender\' OR Gender__c = \'Other\' OR Gender__c = \'M\' OR Gender__c = \'F\')';
		
		return  Database.getQueryLocator(query);
		
	}
	
	global void execute(Database.BatchableContext BC, List<Person_Being_Referred__c> scope){
		List<Person_Being_Referred__c> genderUpdateList = new List<Person_Being_Referred__c>();
		for(Person_Being_Referred__c pbr: scope){
			if(pbr.Gender__c == 'Transgender' || pbr.Gender__c == 'Other'){
				pbr.Gender__c = null;
			}
			else if(pbr.Gender__c == 'M'){
				pbr.Gender__c = 'Male';
			}
			else if(pbr.Gender__c == 'F'){
				pbr.Gender__c = 'Female';
			}
			genderUpdateList.add(pbr);
		}
		
		if(genderUpdateList.size() > 0){
			update genderUpdateList;
		}
	}
	
	global void finish(Database.BatchableContext BC){
		List<String> toAddresses = new List<String>{'adam.vernatter@thementornetwork.com', 'dylan.melnik@thementornetwork.com'};
		//toAddresses.add('adam.vernatter@thementornetwork.com');
		Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('pbrbatchforPersonRegistry');
		mail.setSubject('pbrbatchforPersonRegistry execution is completed.');
		mail.setUseSignature(false);
		string body = 'Batch processing is completed. In production, delete me after you get this message.';
		mail.setplainTextBody(body);
		mail.setSaveAsActivity(false);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
		
	}
 
}