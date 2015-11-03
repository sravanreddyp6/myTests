global class TMNEmployeeLastDayBatch implements Database.Batchable<sObject>, Schedulable {
	private final static date currentDate = system.today();

			global Database.QueryLocator start(Database.BatchableContext BC){

			string query =	'SELECT Id,  First_Name__c,Last_Name__c, Email__c,Manager_First_Name__c,Manager_Last_name__c, Manager_Email__c,LastModifiedDate,Hire_Date__c,Last_Day__c, Manager_Lookup__r.Salesforce_User_Account__c  FROM TMN_user__c ';
				   query += ' where Current_Person_Type__c = \'Employee\' and Last_Day__c = : currentDate ';
				   System.debug('query :' + query);
				return Database.getQueryLocator(query);
			}		
			
			
	global void execute(Database.BatchableContext BC, List<TMN_user__c> scope) {
 		List<Messaging.SingleEmailMessage> mails =   new List<Messaging.SingleEmailMessage>();
					for(TMN_user__c TMNUser:scope){
				List<TMN_User__c> tmnManagerInfo = [select id,name,email__c,Salesforce_User_Account__c from TMN_User__c where Salesforce_User_Account__r.isActive = true and email__c =: TMNUser.Manager_Email__c];
    		if(tmnManagerInfo!=null && tmnManagerInfo.size()>0) {
    			Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
		  String	emailTemplate = '<H4> Hello '+TMNUser.Manager_First_Name__c+' '+ TMNUser.Manager_Last_Name__c + ', </H4>';
					emailTemplate += '<P> You are receiving this message because you are listed as the manager for <B>'+TMNUser.First_Name__c+' '+ TMNUser.Last_Name__c +'</B>  in TMNAccess.';
					emailTemplate += 'The employee account is set to be terminated end of day today and will lose all system access.</P>';	
					emailTemplate += '<P> If you are not the manager for the employee mentioned in this email or have other questions in regards, please either log into TMNAccess ('+URL.getSalesforceBaseUrl().toExternalForm()+'/'+TMNUser.id;
					emailTemplate += ') or contact IT Service Center at 888-774-4872 for assistance. </P> <BR/><BR/>';
					emailTemplate += '<P>This is an automated message sent by the TMNAccess application. If you have any questions or see any discrepancies in the below information please contact the IT Service Center.</P> ';
					emailTemplate += 'Thank you,<BR/> MENTOR IT';
					mail.setTargetObjectId(tmnManagerInfo[0].Salesforce_User_Account__c);
					mail.setHtmlBody(emailTemplate);
					mail.setSubject('Today last day for '+TMNUser.First_Name__c+' '+ TMNUser.Last_Name__c );
					mail.SaveAsActivity = false;
					mails.add(mail);
					}	
			}
				if(mails.size()>0){
				Messaging.sendEmail(mails);			 
				}
	}
			
	
    global void execute(SchedulableContext sc) {
    	Database.executeBatch(new TMNEmployeeLastDayBatch(), 30);
  }

	global void finish(Database.BatchableContext BC) {

	}			
}