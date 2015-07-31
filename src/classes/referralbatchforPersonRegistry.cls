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
		
	}

}