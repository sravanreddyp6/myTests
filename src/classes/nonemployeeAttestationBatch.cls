global class nonemployeeAttestationBatch implements Database.Batchable<sObject>{
	private final static date todayplusone = system.today().addDays(1);
	private final static date todayplusSeven = system.today().addDays(7);
	private final static date todayplusfourteen = system.today().addDays(14);

	global Database.QueryLocator start(Database.BatchableContext BC){
		string query = 'SELECT Id, Job_Status__c, Job_title__c, Last_Day__c, First_Name__c,Termination_Date__c,Last_Name__c, Email__c, Manager_Lookup__c, Manager_Lookup__r.Salesforce_User_Account__c FROM TMN_user__c WHERE Current_Person_Type__c =\'Non-Employee\' AND Job_Status__c = \'Active\'';
		query += ' AND (Last_Day__c = : todayplusone OR Last_Day__c = : todayplusSeven OR Last_Day__c = : todayplusfourteen)';
		system.debug('query============= '+query);
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<TMN_user__c> scope){
		
		Map<id, id> managerMap = new map<id, id>();
		List<Messaging.singleEmailMessage> managermails = new List<Messaging.singleEmailMessage>();
		EmailTemplate managerTemplate = [Select id from EmailTemplate where Name =:'nonEmployeeAttestation'];
		List<Tmn_user__c> nonemployeeList = new List<TMN_user__c>(); // For dummy update So that the workflow can send the email and hence we do not deplete daily email limit - Sravan
		
		for(TMN_user__c u: scope){
			managerMap.put(u.Manager_Lookup__c, u.Manager_Lookup__r.Salesforce_User_Account__c);
			nonemployeeList.add(u);
		}
		
		for(id m: managerMap.keySet()){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setTemplateId(managerTemplate.id);
			mail.setTargetObjectId(managerMap.get(m));
			mail.setWhatId(m);//Populates the Visualforce Email template
			mail.setSenderDisplayName('TMN Access');
			mail.SaveAsActivity = false;
			managermails.add(mail);
		}
		
	
		Messaging.sendEmail(managermails, false); // Send emails. Process goodies even if there is any failure
		update nonemployeeList;
	}

	global void finish(Database.BatchableContext BC){
		
		
	}




}