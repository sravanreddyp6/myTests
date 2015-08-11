public with sharing class nonemployeeAttestationController {
	public Id managerId {get; set;}
	
	//Unable check the size of the map in VF directly. hence defining these - Sravan - 08/03/2015
	public boolean getshowOne(){
		return employeeMap.get(1).size() > 0;
	}
	public boolean getshowSeven(){
		return employeeMap.get(7).size() > 0;
	}
	public boolean getshowFourteen(){
		return employeeMap.get(14).size() > 0;
	}
	
	
	public Map<Integer,List<TMN_User__c>> employeeMap{get{
		List<TMN_User__c> employeeList = [SELECT Id, NAME, Job_Status__c, Job_title__c, Termination_Date__c, First_Name__c, Last_Name__c, Manager_Lookup__c FROM TMN_user__c WHERE Manager_Lookup__c = :managerId AND Current_Person_Type__c = 'Non-Employee'];
			employeeMap = new Map<Integer,List<TMN_User__c>>();
			List<TMN_user__c> employeeOne = new List<TMN_User__c>();
			employeeMap.put(1,employeeOne);
			List<TMN_user__c> employeeSeven = new List<TMN_User__c>();
			employeeMap.put(7,employeeSeven);
			List<TMN_user__c> employeeFourteen = new List<TMN_User__c>();
			employeeMap.put(14,employeeFourteen);
			
		for(TMN_User__c t: employeeList){
			if(Date.Today().daysBetween(t.Termination_Date__c) == 1 ){
				employeeOne.add(t);
				employeeMap.put(1,employeeOne);
			}
			if(Date.Today().daysBetween(t.Termination_Date__c) == 7){
				employeeSeven.add(t);
				employeeMap.put(7,employeeSeven);
			}
			if(Date.Today().daysBetween(t.Termination_Date__c) == 14){
				employeeFourteen.add(t);
				employeeMap.put(14,employeeFourteen);
			}
			
		}
		
		return employeeMap;
	} set;}
	
	
	public TMN_User__c manager {get{
		return [SELECT Id, Name, First_Name__c, Last_name__c FROM TMN_user__c WHERE Id=: managerId];
		
	}private set;}
	
	public string getbaseUrl(){
		return URL.getSalesforceBaseUrl().toExternalForm();
	}
	
	
	public nonemployeeAttestationController(){
		//Constructor
		
	}
	

}