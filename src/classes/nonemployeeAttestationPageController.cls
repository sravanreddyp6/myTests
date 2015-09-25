public without sharing class nonemployeeAttestationPageController {
	public string managerId;
	public Id employeeId{get;set;}
	public string flag {get;set;}
	public List<string> infoMessages;
	public Map<id,Tmn_user__c> initialMap;
	
	public nonemployeeAttestationPageController(){
		managerId = Apexpages.currentPage().getParameters().get('managerId');
		infoMessages = new list<string>();
		initialMap =  new Map<id, TMN_User__c>([SELECT Id, Job_Status__c, Job_title__c, Last_Day__c, First_Name__c, Termination_Date__c ,Last_Name__c, Manager_Lookup__c FROM TMN_user__c WHERE Manager_Lookup__c = :managerId AND Current_Person_Type__c ='Non-Employee' AND Job_Status__c = 'Active' AND Last_Day__c <= :System.Today().addDays(14) order by Last_Day__c asc]);
	}
	
	/*public Map<Integer,List<TMN_User__c>> employeeMap{get{
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
	} set;}*/
	
	public List<TMN_user__c> nonemployeesinitial{get{
		if(nonemployeesinitial == null){
			system.debug('i am not null');
			system.debug('Why i am here again');
			nonemployeesinitial = [SELECT Id, Job_Status__c, Job_title__c, Last_Day__c, First_Name__c, Termination_Date__c ,Last_Name__c, Manager_Lookup__c FROM TMN_user__c WHERE Manager_Lookup__c = :managerId AND Current_Person_Type__c ='Non-Employee' AND Job_Status__c = 'Active' AND Last_Day__c <= :System.Today().addDays(14) order by Last_Day__c asc];
		}
		return nonemployeesinitial;
	}set;}
	
	public list<Tmn_user__c> nonemployeesTransactional{get{
		nonemployeesTransactional = [SELECT Id, Job_title__c, Last_Day__c, First_name__c, Termination_date__c, Last_Name__c, Manager_lookup__c FROM TMN_User__c WHERE Id IN: nonemployeesinitial];
		return nonemployeesTransactional;
	}set;}
	
	public TMN_User__c manager {get{
		return [SELECT Id, Name, First_Name__c, Last_name__c FROM TMN_user__c WHERE Id=: managerId];
		
	}private set;}
	
	/*public boolean getshowOne(){
		system.debug(employeeMap.get(1));
		return employeeMap.get(1).size() > 0;
	}
	
	public boolean getshowSeven(){
		return employeeMap.get(7).size() > 0;
	}
	
	public boolean getshowFourteen(){
		return employeeMap.get(14).size() > 0;
	}*/
	
	
	public pageReference updateTMNUser(){
		
		List<TMN_user__c> nonemployee = [SELECT Id, First_Name__c, Last_name__c,Last_Day__c, Termination_Date__c FROM TMN_User__c WHERE Id=: employeeId LIMIT 1];
		string thankYou = 'Thank you for your response!';
		string additional = 'If you would like to make any additional changes on the accounts please log into TMNAccess.';
		string info = nonemployee[0].Last_Name__c + ' ' +nonemployee[0].First_Name__c;
		if(flag == 'ninety'){
			nonemployee[0].Last_Day__c = nonemployee[0].Last_Day__c.addDays(90);
			info += '\'s account has been extended by 90 days. The new Termination Date is '+nonemployee[0].Last_Day__c.format();	
		}
		else if(flag == 'sixty'){
			nonemployee[0].Last_Day__c = nonemployee[0].Last_Day__c.addDays(60);
			info += '\'s account has been extended by 60 days. The new Termination Date is '+nonemployee[0].Last_Day__c.format();	
		}
		else if(flag == 'thirty'){
			nonemployee[0].Last_Day__c = nonemployee[0].Last_Day__c.addDays(30);
			info += '\'s account has been extended by 30 days. The new Termination Date is '+nonemployee[0].Last_Day__c.format();	
		}
		else if(flag == 'now'){
			nonemployee[0].Last_Day__c = Date.Today();
			info += '\'s account will be terminated by End of Business Today';
		}
		else if(flag == 'termDate'){
			//fill in the termination Date and use it as a flag to avoid sending emails to managers - Sravan- 08/11/2015
			nonemployee[0].Termination_Date__c = nonemployee[0].Last_Day__c;
			info += '\'s account is set to be terminated on '+nonemployee[0].Last_Day__c.format();
		}
		
		try{
			update nonemployee[0];
			infomessages.add(thankYou);
			infomessages.add(info);
			for(string i: infomessages){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, i));
			}
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, additional));
		}
		catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred and hence cannot process your request.'+e.getMessage()));
		}
		return null;
	}

}