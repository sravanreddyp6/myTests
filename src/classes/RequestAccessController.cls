public with sharing class RequestAccessController {


public String selectedTab {set;get;}
public TMN_User__c TMNUser { get;  set; }
		public RequestAccessController() {
		
		 String retURL = ApexPages.currentPage().getParameters().get('retURL');
		Id id = ApexPages.currentPage().getParameters().get('ID');
	TMNUser = [	select name,First_Name__c,Last_Name__c,Manager_Email__c,BAA_Signed__c FROM TMN_User__c 
            WHERE Id = :id];
            	selectedTab = 'Select Access';
		}

}