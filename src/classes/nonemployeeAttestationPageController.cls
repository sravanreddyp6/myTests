public without sharing class nonemployeeAttestationPageController {
	public string managerId;
	public Id employeeId{get;set;}
	public string flag {get;set;}
	public List<string> infoMessages;
	
	public nonemployeeAttestationPageController(){
		managerId = Apexpages.currentPage().getParameters().get('managerId');
		infoMessages = new list<string>();
	}
	
	public Map<Integer,List<TMN_User__c>> employeeMap{get{
		//List<TMN_User__c> employeeList = [SELECT Id, Job_Status__c, Job_title__c, Last_Day__c, First_Name__c,Termination_Date__c ,Last_Name__c, Manager_Lookup__c FROM TMN_user__c WHERE Manager_Lookup__c = :managerId AND Current_Person_Type__c ='Non-Employee' AND Job_Status__c = 'Active'];
			employeeMap = new Map<Integer,List<TMN_User__c>>();
			List<TMN_user__c> employeeOne = new List<TMN_User__c>();
			employeeMap.put(1,employeeOne);
			List<TMN_user__c> employeeSeven = new List<TMN_User__c>();
			employeeMap.put(7,employeeSeven);
			List<TMN_user__c> employeeFourteen = new List<TMN_User__c>();
			employeeMap.put(14,employeeFourteen);
			
		for(TMN_User__c t: [SELECT Id, Job_Status__c, Job_title__c, Last_Day__c, First_Name__c, Termination_Date__c ,Last_Name__c, Manager_Lookup__c FROM TMN_user__c WHERE Manager_Lookup__c = :managerId AND Current_Person_Type__c ='Non-Employee' AND Job_Status__c = 'Active']){
			if(Date.Today().daysBetween(t.Last_Day__c) == 1 && t.Last_Day__c != t.termination_Date__c){
				employeeOne.add(t);
				employeeMap.put(1,employeeOne);
			}
			if(Date.Today().daysBetween(t.Last_Day__c) == 7 && t.Last_Day__c != t.termination_Date__c){
				employeeSeven.add(t);
				employeeMap.put(7,employeeSeven);
			}
			if(Date.Today().daysBetween(t.Last_Day__c) == 14 && t.Last_Day__c != t.termination_Date__c){
				employeeFourteen.add(t);
				employeeMap.put(14,employeeFourteen);
			}
			
		}
		
		system.debug('expiring tomorrow'+employeeMap.get(1));
		return employeeMap;
	} set;}
	
	public TMN_User__c manager {get{
		return [SELECT Id, Name, First_Name__c, Last_name__c FROM TMN_user__c WHERE Id=: managerId];
		
	}private set;}
	
	public boolean getshowOne(){
		system.debug(employeeMap.get(1));
		return employeeMap.get(1).size() > 0;
	}
	
	public boolean getshowSeven(){
		return employeeMap.get(7).size() > 0;
	}
	
	public boolean getshowFourteen(){
		return employeeMap.get(14).size() > 0;
	}
	
	
	public pageReference updateTMNUser(){
		
		List<TMN_user__c> nonemployee = [SELECT Id, First_Name__c, Last_name__c,Last_Day__c, Termination_Date__c FROM TMN_User__c WHERE Id=: employeeId LIMIT 1];
		string info = 'Thank You! '+nonemployee[0].Last_Name__c + ' ' +nonemployee[0].First_Name__c;
		if(flag == 'ninety'){
			nonemployee[0].Last_Day__c = nonemployee[0].Last_Day__c.addDays(90);
			info += '\'s last date is extended till '+nonemployee[0].Last_Day__c.format();	
		}
		else if(flag == 'sixty'){
			nonemployee[0].Last_Day__c = nonemployee[0].Last_Day__c.addDays(60);
			info += '\'s last date is extended till '+nonemployee[0].Last_Day__c.format();	
		}
		else if(flag == 'thirty'){
			nonemployee[0].Last_Day__c = nonemployee[0].Last_Day__c.addDays(30);
			info += '\'s last date is extended till '+nonemployee[0].Last_Day__c.format();	
		}
		else if(flag == 'now'){
			nonemployee[0].Last_Day__c = Date.Today();
			info += ' is termniated now';
		}
		else if(flag == 'termDate'){
			//fill in the termination Date and use it as a flag to avoid sending emails to managers - Sravan- 08/11/2015
			nonemployee[0].Termination_Date__c = nonemployee[0].Last_Day__c;
			info += '\'s last date will be on '+nonemployee[0].Last_Day__c.format();
		}
		
		try{
			update nonemployee[0];
			infomessages.add(info);
			for(string i: infomessages){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, i));
			}
		}
		catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred and hence cannot process your request.'+e.getMessage()));
		}
		return null;
	}

}