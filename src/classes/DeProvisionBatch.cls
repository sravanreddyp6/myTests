global class DeProvisionBatch implements Database.Batchable<sObject>, Schedulable {


	private final static date currentDate = system.today();

	global Database.QueryLocator start(Database.BatchableContext BC){
		
		string query = 'SELECT Id,identity_id__c,  First_Name__c,Last_Name__c, Email__c,Manager_Email__c, Manager_First_Name__c,Manager_Last_name__c,LastModifiedDate,Hire_Date__c,Job_Status__c,Last_Day__c  FROM TMN_user__c WHERE ';
		query += ' Last_Day__c = : currentDate';
		query += ' OR (lastModifiedDate = :currentDate and last_day__c <= :currentDate)';
		system.debug('query============= '+query);
		return Database.getQueryLocator(query);
	}

			global void execute(Database.BatchableContext BC, List<TMN_user__c> scope){
					List<OrgWideEmailAddress> owa = [Select id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName = 'TMN Access' LIMIT 1];
					List<User> userList = [select id,name,firstname,lastname ,email from user where firstname='easy' and lastname ='vista' limit 1];
			       	List<Messaging.SingleEmailMessage> mails =   new List<Messaging.SingleEmailMessage>();
					for(TMN_User__c tmn:scope) {
    				Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
    				String	emailTemplate = 'This message is an automated notification from TMNAccess: Workforce. Because the last day value in TMNAccess: Workforce is today a deprovisioning event has been triggered for '+tmn.First_Name__c+' '+tmn.Last_Name__c+'.';
    				emailTemplate += '<BR/>';
    				emailTemplate += '<BR/>';
    				emailTemplate += '<BR/>';
    				emailTemplate += '<BR/> @RECIPIENTADDRESS@={'+tmn.identity_id__c+'}';
					emailTemplate += '<BR/> @CODE_CATALOG@=\'depro\'';
            		mail.setTargetObjectId(userList[0].id);
         			mail.setSubject('De Provision for '+tmn.Last_Name__c+' '+tmn.First_Name__c);
         			mail.setHtmlBody(emailTemplate);
                    mail.SaveAsActivity = false; 
                    mail.setOrgWideEmailAddressId(owa[0].Id);
         			mails.add(mail);
                    }	
		Messaging.sendEmail(mails);						
	}   

	global void execute(SchedulableContext sc) {
    	Database.executeBatch(new DeProvisionBatch(), 30);
  }

	global void finish(Database.BatchableContext BC) {

	}	

}