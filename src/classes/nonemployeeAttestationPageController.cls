public without sharing class nonemployeeAttestationPageController {
	public string managerId;
	public Id employeeId{get;set;}
	public string flag {get;set;}
	public List<string> infoMessages;
	public Date lastDay {get;set;}
	public date dateChoosen {get; set;}
	public string dateChoosenString {get; set;}
	public string max {get; set;}
	public string min {get; set;}
	public Map<id,nonEmployee> lineItemsmap {get; set;}
	public list<nonEmployee> lineItems {get; set;}
	
	public nonemployeeAttestationPageController(){
		managerId = Apexpages.currentPage().getParameters().get('managerId');
		infoMessages = new list<string>();
		max = system.Now().addDays(90).format('YYYY-MM-dd');
		min = system.Now().format('YYYY-MM-dd');
		lineItemsmap = new Map<id,nonEmployee>();
		for(TMN_User__c t: nonemployeesinitial){
			lineItemsmap.put(t.Id, new nonEmployee(t));
		}
		lineItems = lineItemsmap.values();
	}
	
	public List<TMN_user__c> nonemployeesinitial{get{
		if(nonemployeesinitial == null){
			nonemployeesinitial = [SELECT Id, Job_Status__c, Job_title__c, Last_Day__c, First_Name__c, Termination_Date__c ,Last_Name__c, Manager_Lookup__c, LastmodifiedBy.name FROM TMN_user__c WHERE Manager_Lookup__c = :managerId AND Current_Person_Type__c ='Non-Employee' AND Job_Status__c = 'Active' AND Last_Day__c <= :System.Today().addDays(14) order by Last_Day__c asc];
		}
		return nonemployeesinitial;
	}set;}
	
	public TMN_User__c manager {get{
		return [SELECT Id, Name, First_Name__c, Last_name__c FROM TMN_user__c WHERE Id=: managerId];
		
	}private set;}
	
	public pageReference updateTMNUser(){
		//List<TMN_user__c> nonemployee = [SELECT Id, First_Name__c, Last_name__c,Last_Day__c, Termination_Date__c FROM TMN_User__c WHERE Id=: employeeId LIMIT 1];
		dateChoosenString = ApexPages.currentpage().getParameters().get('dateChoosenString');
		nonEmployee n = lineItemsmap.get(employeeId);
		TMN_user__c current = lineItemsmap.get(employeeId).tmnUser;
		string thankYou = 'Thank you for your response!';
		string additional = 'If you would like to make any additional changes on the accounts please log into TMNAccess.';
		string info = current.Last_Name__c + ' ' +current.First_Name__c;
		if(flag == 'ninety'){
			n.updated = true;
			current.Last_Day__c = current.Last_Day__c.addDays(90);
			info += '\'s account has been extended by 90 days. The new Termination Date is '+current.Last_Day__c.format();	
		}
		else if(flag == 'sixty'){
			n.updated = true;
			current.Last_Day__c = current.Last_Day__c.addDays(60);
			info += '\'s account has been extended by 60 days. The new Termination Date is '+current.Last_Day__c.format();	
		}
		else if(flag == 'thirty'){
			n.updated = true;
			current.Last_Day__c = current.Last_Day__c.addDays(30);
			info += '\'s account has been extended by 30 days. The new Termination Date is '+current.Last_Day__c.format();	
		}
		else if(flag == 'now'){
			n.updated = true;
			current.Last_Day__c = Date.Today();
			info += '\'s account will be terminated by End of Business Today';
		}
		else if(flag == 'Other'){
			n.updated = true;
			current.Last_day__c = Date.valueOf(dateChoosenString);
			info += '\'s account is set to be terminated on '+current.Last_Day__c.format();
		}
		try{
			update current;
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
	
	public class nonEmployee{
		public TMN_user__c tmnUser{get; set;}
		public boolean updated {get; set;}
		
		public nonEmployee(TMN_user__c tmnuser){
			this.tmnuser = tmnuser;
			this.updated = false;
		}
		
	}
	
	public void openModalDialog(){
		//dateChoosen = lineItemsmap.get(employeeId).tmnUser.Last_Day__c;
		//Just for action on the button tom to pass in paramters 
	}
	
	public void setparams(){
		//dummy to set paramter values
	}
	
	

}