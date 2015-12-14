global class TMNEmployeeJobStatusBatch implements Database.Batchable<sObject>, Schedulable {

private final static date currentDate = system.today();

	global Database.QueryLocator start(Database.BatchableContext BC){
		
		string query = 'SELECT Id,  First_Name__c,Last_Name__c, Email__c,Manager_Email__c, Manager_First_Name__c,Manager_Last_name__c,LastModifiedDate,Hire_Date__c,Job_Status__c,Last_Day__c  FROM TMN_user__c WHERE Job_Status__c = \'Active\'';
		query += '  and Manager_Email__c <> \'\'  and Current_Person_Type__c =\'Employee\' and Last_Day__c = : currentDate';
		system.debug('query============= '+query);
		return Database.getQueryLocator(query);
	}

			global void execute(Database.BatchableContext BC, List<TMN_user__c> scope){
				List<OrgWideEmailAddress> owa = [Select id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName = 'TMN Access' LIMIT 1];
			       List<Messaging.SingleEmailMessage> mails =   new List<Messaging.SingleEmailMessage>();
								
					for(TMN_User__c tmn:scope) {
   					List<TMN_User__c> tmnManagerInfo = [select id,name,email__c,Salesforce_User_Account__c from TMN_User__c where Salesforce_User_Account__r.isActive = true and email__c =: tmn.Manager_Email__c];
    				if(tmnManagerInfo!=null && tmnManagerInfo.size()>0) {
    				Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
    				String	emailTemplate = '<H4> Hello '+tmn.Manager_First_Name__c+' '+ tmn.Manager_Last_Name__c + ', </H4>';
					emailTemplate += '<P> You are receiving this message because you are listed as the manager for <B>'+tmn.First_Name__c+' '+ tmn.Last_Name__c +'</B>  in TMNAccess.';
					emailTemplate += 'The employee job status changed to inactive today.</P>';	
					emailTemplate += '<P> If you are not the manager for the employee mentioned in this email or have other questions in regards, please either log into TMNAccess ('+URL.getSalesforceBaseUrl().toExternalForm()+'/'+tmn.id;
					emailTemplate += ') or contact IT Service Center at 888-774-4872 for assistance. </P> <BR/><BR/>';
					emailTemplate += '<P>This is an automated message sent by the TMNAccess application. If you have any questions or see any discrepancies in the below information please contact the IT Service Center.</P> ';
					emailTemplate += 'Thank you,<BR/> MENTOR IT.';
            		mail.setTargetObjectId(tmnManagerInfo[0].Salesforce_User_Account__c);
         			mail.setSubject('Job Status changed for '+tmn.Last_Name__c+' '+tmn.First_Name__c);
         			mail.setHtmlBody(emailTemplate);
                    mail.SaveAsActivity = false; 
                    mail.setOrgWideEmailAddressId(owa[0].Id);
         			mails.add(mail);
         		    tmn.Job_Status__c = 'Inactive';
         		    List<TMN_User_Delegate__c>	delegateList  = [SELECT id,Delegate_for_Name__c,TMN_Delegate_For__c,Delegate_for_Email__c,Delegation_Complete__c,TMN_Delegate_Name__c FROM TMN_User_Delegate__c where TMN_Delegate_Name__c = : tmn.id];
				if(delegateList.size()>0) {
					delete delegateList;
				}
				
                    }	
		}								
		update scope;
		  Messaging.sendEmail(mails);						
	}   

	global void execute(SchedulableContext sc) {
    	Database.executeBatch(new TMNEmployeeJobStatusBatch(), 30);
  }

	global void finish(Database.BatchableContext BC) {

	}	

}