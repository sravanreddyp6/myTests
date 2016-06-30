public with sharing class rptCurrent_Combined_ISPs {
	
    public list<Case_Management_Plan__c> rptData {get; set;}
    
	public rptCurrent_Combined_ISPs() {
		runRpt();
	}
    
    public pageReference runRpt(){
    	boolean inputErr = false;
    	ApexPages.getMessages().clear();
    
		rptData = [SELECT Id, Service_Assignment__r.Person_Being_Served__r.Name, Service_Assignment__c,
					Service_Assignment__r.Name, Service_Assignment__r.Person_Being_Served__c, Name, 
					PD_Start__c, PD_End__c, Status__c, CreatedBy.Name, LastModifiedBy.Name, LastModifiedDate
					FROM Case_Management_Plan__c
					WHERE RecordType.DeveloperName = 'OR_Combined_ISP' AND
						Status__c in ('Inactive Draft', 'Active Final')
					];
		
    	return null; 
    }
}