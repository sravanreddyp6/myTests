public with sharing class rptProviderTracking {
	
	public list<TMN_Provider__c> rptData {get; set;}
	
	public String providerStatus {get; set;}
	public String brokerage {get; set;}
	
	public rptProviderTracking() {
		runRpt();
	}
    
    public PageReference runRpt() {
		rptData = [SELECT Id, First_Name__c, Last_Name__c, Gender__c, SPD_Number__c, eXPRS_Number__c, Address_Street_1__c,
						Address_Street_2__c, City__c, State__c, Zip__c, Phone_1__c, Phone_2__c, Fax__c, Primary_Email__c,
						Provider_Type__c, Company_Agency_Name__c, Brokerage__r.Alias__c, Counties_Served__c,  
						Services_Provided__c, Status__c, (SELECT Disqualification_Date__c, Effective_Date__c, Expiration_Date__c 
							FROM TMN_Provider_Applications__r ORDER BY Effective_Date__c DESC LIMIT 1)
					FROM TMN_Provider__c
					];
		
    	return null; 
    }
}