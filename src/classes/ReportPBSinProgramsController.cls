public with sharing class ReportPBSinProgramsController {
	
	public Date fromDate {get;set;}
	public Date toDate {get;set;}
		
	public ReportPBSinProgramsController(){
		
	}
	
	
	
	@RemoteAction
	//Perfroming the SOQ; string generation in Remote action as apex has built in methods to parse the data easily - Sravan - 17/11/2015
	public static Service_Location__c[] getServiceAssignments(string fromD, string toD){
		//Date fromDate = Date.parse(fromD);
		//Date toDate = Date.parse(toD);
		
		string SOQL = 'SELECT Id, Name FROM Service_location__c WHERE Id!= null';
		//SOQL +='Start_Date__c > :fromDate';
		
		Service_Location__c[] servAssigns = Database.Query(SOQL);
		return servAssigns;
		
	}

}