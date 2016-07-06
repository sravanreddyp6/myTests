public with sharing class rptProviderTracking {
	
	public list<TMN_Provider__c> rptData {get; set;}
	
	public rptProviderTracking() {
		runRpt();
	}
    
    public PageReference runRpt() {
		rptData = [SELECT Id, Name, Brokerage__r.Alias__c, Company_Agency_Name__c, Counties_Served__c, State__c, 
						eXPRS_Number__c, Status__c
					FROM TMN_Provider__c
					];
		
    	return null; 
    }
}