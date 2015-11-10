global class CopyAccountSoundExBatch implements Database.Batchable<sObject>{
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		
		string query = 'Select id,Last_Name_Soundex_Key__c,First_Name_Soundex_Key__c,Last_Name_SoundEx_Key__pc,First_Name_Soundex_Key__pc from account where First_Name_Soundex_Key__pc =\'\' ';
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Account> scope){
		
		for(Account ac: scope){
			ac.Last_Name_SoundEx_Key__pc = ac.Last_Name_Soundex_Key__c;
   			ac.First_Name_Soundex_Key__pc = ac.First_Name_Soundex_Key__c;
		}
		
		update scope; 
	}

	global void finish(Database.BatchableContext BC){
		
		
	}
	
    
}