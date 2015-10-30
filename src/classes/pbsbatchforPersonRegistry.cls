global class pbsbatchforPersonRegistry implements Database.Batchable<sObject>{
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		string query = 'SELECT Id, Gender__c, Does_the_person_Identify__c, Gender_Identity__c, Guardianship_Type__c, Legal_Guardianship_Status__c FROM Contact';
		
		return  Database.getQueryLocator(query);
		
	}
	
	global void execute(Database.BatchableContext BC, List<Contact> scope){
		List<Contact> genderUpdateList = new List<Contact>();
		for(Contact pbs: scope){
			if(pbs.Gender__c == 'Transgender' || pbs.Gender__c == 'Other'){
				pbs.Does_the_person_Identify__c = 'Yes';
				//Sravan - Confirmed with Kristen and added below line- PRI-110
				pbs.Gender_Identity__c = pbs.Gender__c;
				pbs.Gender__c = null;
				if(pbs.Legal_Guardianship_Status__c == 'Self'){
					pbs.Guardianship_Type__c = 'Self';
				}
				genderUpdateList.add(pbs);
			}
			
			else if(!(pbs.Gender__c == 'Transgender' || pbs.Gender__c == 'Other')){
					pbs.Does_the_person_Identify__c = 'No';
					if(pbs.Gender__c == 'M'){
						pbs.Gender__c = 'Male';
					}
					if(pbs.Gender__c == 'F'){
						pbs.Gender__c = 'Female';
					}
					if(pbs.Legal_Guardianship_Status__c == 'Self'){
						pbs.Guardianship_Type__c = 'Self';
					}
				genderUpdateList.add(pbs);	
			}

		}
		
		if(genderUpdateList.size() > 0){
			update genderUpdateList;
		}
	}
	
	global void finish(Database.BatchableContext BC){
		
		List<String> toAddresses = new List<String>{'adam.vernatter@thementornetwork.com', 'dylan.melnik@thementornetwork.com'};
		//toAddresses.add('adam.vernatter@thementornetwork.com', 'dylan.melnik@thementornetwork.com');
		Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('pbsbatchforPersonRegistry');
		mail.setSubject('pbsbatchforPersonRegistry batch execution is completed.');
		mail.setUseSignature(false);
		string body = 'Batch processing is completed. In production, delete me after you see this message.';
		mail.setplainTextBody(body);
		mail.setSaveAsActivity(false);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
		
	}

}