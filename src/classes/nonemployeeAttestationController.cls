public with sharing class nonemployeeAttestationController {
	public Id managerId {get; set;}
	public TMN_User__c manager {get{
		return [SELECT Id, Name, First_Name__c, Last_name__c FROM TMN_user__c WHERE Id=: managerId];
		
	}private set;}
	
	Public List<TMN_user__c> nonemployees{get{
		if(nonemployees == null){
			nonemployees = [SELECT Id, Job_Status__c, Job_title__c, Last_Day__c, First_Name__c, Termination_Date__c ,Last_Name__c, Manager_Lookup__c FROM TMN_user__c WHERE Manager_Lookup__c = :managerId AND Current_Person_Type__c ='Non-Employee' AND Job_Status__c = 'Active' AND Last_Day__c <= :System.Today().addDays(14) order by Last_Day__c asc];
		}
		return nonemployees;
	}set;}
	
	public string getbaseUrl(){
		Site_URL__c s = Site_URL__c.getValues('NonemployeeAttestationSite');
		return s.Prefix__c;
	}
	
	public nonemployeeAttestationController(){
		//Constructor
		
	}
	

}