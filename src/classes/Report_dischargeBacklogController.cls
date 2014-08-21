public with sharing class Report_dischargeBacklogController {
    public List<Service_Assignment__c>lineItems { get;set; }
    public Boolean displayResult{get ; set ;}

    public Report_dischargeBacklogController(){
        lineItems = new List<Service_Assignment__c>();
        displayResult = false;
    }
    
    public pageReference runReport(){
    	displayResult = true;
    	List<Service_Assignment__c> excludeItems = [SELECT ID, NAME FROM Service_Assignment__c WHERE Model__c='FCT' AND Status__c ='Active' AND ID IN (SELECT Service_Assignment__c FROM Progress_Note__c WHERE Start_Time__c > :Date.Today().addDays(-14))];
    	
		List<Progress_Note__c> notes = [SELECT ID, Start_Time__c, Service_Assignment__c FROM Progress_Note__c WHERE Service_Assignment__r.Model__c = 'FCT' AND Service_Assignment__r.Status__c='Active' AND Service_Assignment__c NOT IN:excludeItems];
		set<id> ids = new set<id>();
    	for(Progress_note__c pn : notes){
    		ids.add(pn.Service_Assignment__c);
			}
        lineItems = [SELECT ID, NAME,Admission__r.State__c, Admission__r.Person_Being_Served__r.Name,Alias__c,Start_Date__c,Program_Detail__c,Status__c,(SELECT Start_Time__c FROM Progress_notes__r  order by Start_Time__c desc LIMIT 1),(SELECT Id,Status__c FROM Service_Assignment_Closures__r LIMIT 1  )FROM Service_Assignment__c  WHERE Model__c='FCT' AND Status__c ='Active' AND Id IN :ids];
	
        return null;
    }
    

}