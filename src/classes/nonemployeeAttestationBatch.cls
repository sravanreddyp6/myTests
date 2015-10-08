global class nonemployeeAttestationBatch implements Database.Batchable<sObject>{
	private final static date todayplusone = system.today().addDays(1);
	private final static date todayplusSeven = system.today().addDays(7);
	private final static date todayplusfourteen = system.today().addDays(14);

	global Database.QueryLocator start(Database.BatchableContext BC){
		string query = 'SELECT Id, Job_Status__c, Job_title__c, Last_Day__c, First_Name__c,Termination_Date__c,Last_Name__c, Manager_Lookup__c, Manager_Lookup__r.Salesforce_User_Account__c FROM TMN_user__c WHERE Current_Person_Type__c =\'Non-Employee\' AND Job_Status__c = \'Active\'';
		query += ' AND (Last_Day__c = : todayplusone OR Last_Day__c = : todayplusSeven OR Last_Day__c = : todayplusfourteen)';
		system.debug('query============= '+query);
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<TMN_user__c>scope){
		
		Map<id, id> managerMap = new map<id, id>();
		List<Messaging.singleEmailMessage> mails = new List<Messaging.singleEmailMessage>();
		EmailTemplate myEMailTemplate = [Select id from EmailTemplate where Name =:'nonEmployeeAttestation'];
		
		for(TMN_user__c u: scope){
			if(u.Last_Day__c != u.Termination_Date__c){
				managerMap.put(u.Manager_Lookup__c, u.Manager_Lookup__r.Salesforce_User_Account__c);
			}
		}
		
		for(id m: managerMap.keySet()){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setTemplateId(myEMailTemplate.id);
			mail.setTargetObjectId(managerMap.get(m));
			mail.setWhatId(m);//Populates the Visualforce Email template
			mail.setSenderDisplayName('TMN Access');
			mail.SaveAsActivity = false;
			mails.add(mail);
		}
	
		Messaging.sendEmail(mails, false); // Send emails. Process goodies even if there is any failure 
	}

	global void finish(Database.BatchableContext BC){
		
		
	}




}