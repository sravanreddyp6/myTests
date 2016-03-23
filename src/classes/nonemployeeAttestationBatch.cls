global class nonemployeeAttestationBatch implements Database.Batchable<sObject>, Schedulable{
	private final static date todayplusone = system.today().addDays(1);
	private final static date todayplusSeven = system.today().addDays(7);
	private final static date todayplusfourteen = system.today().addDays(14);

	global Database.QueryLocator start(Database.BatchableContext BC){
		
		
		string query = 'SELECT Id, Job_Status__c, Job_title__c, Last_Day__c, First_Name__c,Termination_Date__c,Last_Name__c, Email__c, Manager_Email__c, Manager_Lookup__c, Manager_Lookup__r.Email__c, Manager_Lookup__r.Salesforce_User_Account__c, Manager_Lookup__r.Salesforce_User_Account__r.isActive, Manager_Lookup__r.Salesforce_User_Account__r.Email FROM TMN_user__c WHERE Current_Person_Type__c =\'Non-Employee\' AND Job_Status__c = \'Active\'';
		query += ' AND (Last_Day__c = : todayplusone OR Last_Day__c = : todayplusSeven OR Last_Day__c = : todayplusfourteen)';
		system.debug('query============= '+query);
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<TMN_user__c> scope){
		
		map<id, id> managerMap = new map<id, id>();
		map<id,string> nonSfManagersMap = new map<id,string>();
		map<id,id> dummynonSFMap = new Map<id, id>(); 
		map<id,string> userIdEmailMap = new Map<id, string>();
		
		List<Messaging.singleEmailMessage> managermails = new List<Messaging.singleEmailMessage>();
		List<Messaging.singleEmailMessage> nonSfManagersmails = new List<Messaging.singleEmailMessage>();
		EmailTemplate managerTemplate = [Select id from EmailTemplate where Name =:'nonEmployeeAttestation'];
		List<OrgWideEmailAddress> owa = [Select id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName = 'TMN Access' LIMIT 1];
		
		for(TMN_user__c u: scope){
			if(string.isNotBlank(u.Manager_Lookup__r.Salesforce_User_Account__c) && u.Manager_Lookup__r.Salesforce_User_Account__r.isActive){
				managerMap.put(u.Manager_Lookup__c, u.Manager_Lookup__r.Salesforce_User_Account__c);
				if(Error_logger__c.getOrgDefaults().nonemployee_Manager_Emails__c){ //Required only for error logging
					userIdEmailMap.put(u.Manager_Lookup__r.Salesforce_User_Account__c, u.Manager_Lookup__r.Salesforce_User_Account__r.Email);
				}
			}else{
				nonSfManagersMap.put(u.Manager_Lookup__c, u.Manager_Lookup__r.Email__c);
				dummynonSFMap.put(u.Manager_Lookup__c, Userinfo.getUserId()); //using dummy user Id to populate the Template
			}
			
		}
		
		for(id m: managerMap.keySet()){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setTemplateId(managerTemplate.id);
			mail.setTargetObjectId(managerMap.get(m));
			mail.setWhatId(m);//Populates the Visualforce Email template
			mail.setOrgWideEmailAddressId(owa[0].Id);
			mail.SaveAsActivity = false;
			managermails.add(mail);
		}
		
		for(id m: nonSfManagersMap.keySet()){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setTemplateId(managerTemplate.id);
			mail.setTargetObjectId(dummynonSFMap.get(m));
			mail.toAddresses = new string[]{nonSfManagersMap.get(m)};
			mail.setWhatId(m);//Populates the Visualforce Email template
			mail.setOrgWideEmailAddressId(owa[0].Id);
			mail.SaveAsActivity = false;
			nonSfManagersmails.add(mail);
		}
		
		Savepoint sp = Database.setSavepoint();
		Messaging.sendEmail(nonSfManagersmails);
		Database.rollback(sp); //Emails are not sent since the transaction is rolled back. Email content generated here is used to Set the content below
		
		List<Messaging.SingleEmailMessage> nonSFmailstoSend = new List<Messaging.SingleEmailMessage>();
		for (Messaging.SingleEmailMessage email : nonSfManagersmails) {
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setToAddresses(email.getToAddresses());
				mail.setPlainTextBody(email.getPlainTextBody());
				mail.setHTMLBody(email.getHTMLBody());
				mail.setSubject(email.getSubject());
				mail.setOrgWideEmailAddressId(owa[0].Id);
			
				nonSFmailstoSend.add(mail);
		}
		
		List<Messaging.SendEmailResult> sfResults = Messaging.sendEmail(managermails, false); // Send emails to Managers who have salesforce Account. Process goodies even if there is any failure
		List<Messaging.SendEmailResult> nonsfResults = Messaging.sendEmail(nonSFmailstoSend, false); // Send emails to non SF Managers. Process goodies even if there is any failure
		
		if(Error_logger__c.getOrgDefaults().nonemployee_Manager_Emails__c){ //run this only if error logger custom setting is on
			string successMessage = '<b>Email is successfully delivered to the following emails. </b><br/>';
			string failedMessage = '<b>Email delivery process failed for the following emails </b><br/>';
			for(integer i=0; i<sfResults.size(); i++){
				successMessage = successMessage +'<i>Managers with Active Salesforce Account<i/> <br/>';
				if(sfResults.get(i).isSuccess()){
					successMessage = successMessage + userIdEmailMap.get(managermails.get(i).getTargetObjectId()) + '<br/>';
				}else{
					failedMessage = failedMessage +managermails.get(i).getToAddresses() + '----Reason:'+sfResults.get(i).getErrors()+' <br/>'; 
				}
			}
			
			for(integer i=0; i<nonsfResults.size(); i++){
				successMessage = successMessage + '<i>Managers with InActive/No Salesforce Account<i/> <br/>';
				if(nonsfResults.get(i).isSuccess()){
					successMessage = successMessage + nonSFmailstoSend.get(i).getToAddresses() + '<br/>';
				}else{
					failedMessage = failedMessage +nonSFmailstoSend.get(i).getToAddresses() + '----Reason:'+nonsfResults.get(i).getErrors()+' <br/>'; 
				}
			}
			
			Error_log__c errorlog = new Error_log__c();
			errorlog.Name = 'Email log for nonemployee Managers on '+System.Today().format(); 
			errorlog.Email_Delivery_Result__c = successMessage + '<br/> <br/>'+failedMessage;
			errorlog.Class_and_Method__c = 'nonemployeeAttestationBatch - execute method';
			
			insert errorlog;
		}
		
		
		/*List<Database.SaveResult> srList = Database.update(scope, false); //For dummy update So that the workflow can send the email and hence we do not deplete daily email limit - Sravan
		Id job = System.enqueueJob(new errorLogger(srList, scope, 'nonemployeeAttestationBatch - Execute method'));
		//Id job2 = System.enqueueJob(new errorLogger(scope));
		system.debug('Done with error logging');*/
	}

	global void finish(Database.BatchableContext BC){
		
		
	}
	
	//Scheduling the batch
    global void execute(SchedulableContext sc) {
    	Database.executeBatch(new nonemployeeAttestationBatch(), 30);
  }




}