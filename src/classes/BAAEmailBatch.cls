global class BAAEmailBatch implements Database.Batchable<sObject>, Schedulable {

	private final static date currentDate = system.today();

	global Database.QueryLocator start(Database.BatchableContext BC){
		
		string query = 'SELECT Id,  First_Name__c,Last_Name__c, Email__c, Manager_Email__c,LastModifiedDate,Hire_Date__c,Manager_Lookup__r.Salesforce_User_Account__c  FROM TMN_user__c WHERE Current_Person_Type__c =\'Non-Employee\' AND Job_Status__c = \'Active\'';
		query += '  AND BAA_Signed__c = false AND (Vendor_list__c=\'OTHER\' OR Vendor_list__c=\'INDEPENDENT CONTRACTOR\' ) and Manager_Email__c <> \'\' ';
		system.debug('query============= '+query);
		return Database.getQueryLocator(query);
	}

			global void execute(Database.BatchableContext BC, List<TMN_user__c> scope){
			       List<Messaging.SingleEmailMessage> mails =   new List<Messaging.SingleEmailMessage>();
								
					for(TMN_User__c tmn:scope) {
   					if(tmn.hire_date__C.daysBetween(currentDate)==1 || tmn.hire_date__C.daysBetween(currentDate)==7 || tmn.hire_date__C.daysBetween(currentDate)==14 || tmn.hire_date__C.daysBetween(currentDate)>14){
   						
   					List<TMN_User__c> tmnManagerInfo = [select id,name,email__c,Salesforce_User_Account__c from TMN_User__c where Salesforce_User_Account__r.isActive = true and email__c =: tmn.Manager_Email__c];
    				if(tmnManagerInfo!=null && tmnManagerInfo.size()>0) {
   					Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
            		mail.setTargetObjectId(tmnManagerInfo[0].Salesforce_User_Account__c);
         			mail.setSubject('Reminder : Mising BAA requirement');
         			String body = 'Missing required BAA attachment for '+tmn.Last_Name__c+','+tmn.First_Name__c;
         			mail.setHtmlBody(body);
                    mail.SaveAsActivity = false; 
                    	   
         			mails.add(mail);
                    }	
				}
		}								
		  Messaging.sendEmail(mails);						
	}   

	global void execute(SchedulableContext sc) {
    	Database.executeBatch(new BAAEmailBatch(), 30);
  }

	global void finish(Database.BatchableContext BC) {

	}	

}