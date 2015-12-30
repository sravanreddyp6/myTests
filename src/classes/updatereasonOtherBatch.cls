global class updatereasonOtherBatch implements Database.batchable<sObject>{
    
    global Database.QueryLocator Start(Database.batchableContext BC){
        string s = 'SELECT Id, Reason_For_Discharge__c, Reason_other__c FROM Admission__c WHERE Network_offering__c = \'ABI\' AND Reason_For_Discharge__c != null';
        return Database.getQueryLocator(s);
    }
    
    global void execute(Database.BatchableContext BC, List<Admission__c> scope){
    	List<Admission__c> tobeUpdated = new List<Admission__c>();
        for(Admission__c ad : scope){
        	ad.Reason_other__c = ad.Reason_For_Discharge__c;
        	
        }
        update scope;
    }
    
     global void finish(Database.BatchableContext BC){
        
    }
    
    
   
}