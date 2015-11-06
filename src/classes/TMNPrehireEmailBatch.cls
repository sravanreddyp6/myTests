global class TMNPrehireEmailBatch implements Database.Batchable<sObject>, Schedulable {
	
	
	private final static date todayminusfifteen = system.today().addDays(-15);
	private final static date currentDate = system.today();

			global Database.QueryLocator start(Database.BatchableContext BC){
			string query =	'SELECT Id,  First_Name__c,Last_Name__c, Email__c,Manager_First_Name__c,Manager_Last_name__c, Manager_Email__c,LastModifiedDate,Hire_Date__c,Last_Day__c,Recruiter_Name__c,Recruiter_Email_Address__c,Job_Status__c  FROM TMN_user__c ';
				   query += ' where  Recruiter_Email_Address__c <> \'\' and Current_Person_Type__c = \'Pre-hire\'  and Job_Status__c=\'Active\' and Hire_Date__c > :todayminusfifteen'; 
				   // I am putting minus 15 days beacuse I need max 8th business days [max 8th business day from Friday is 12, I am putting some extra days]
				   System.debug('query :' + query);
				return Database.getQueryLocator(query);
			}		
			
			
	global void execute(Database.BatchableContext BC, List<TMN_user__c> scope) {
 		List<Messaging.SingleEmailMessage> mails =   new List<Messaging.SingleEmailMessage>();
					for(TMN_user__c TMNUser:scope){
				List<TMN_User__c> recruiterInfo = [select id,name,email__c,Salesforce_User_Account__c from TMN_User__c where Salesforce_User_Account__r.isActive = true and email__c =: TMNUser.Recruiter_Email_Address__c];
    		if(recruiterInfo!=null && recruiterInfo.size()>0) {
    			Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
		  String	emailTemplate1 = '<H4> Hello '+TMNUser.Recruiter_Name__c + ', </H4>';
					emailTemplate1 += '<P> You are receiving this message because you are listed as the recruiter for Pre-Hire <B>('+TMNUser.First_Name__c+' '+ TMNUser.Last_Name__c +')</B>  in TMNAccess ';
					emailTemplate1 += 'who was scheduled to start with The Mentor network as of '+TMNUser.Hire_Date__c.format()+'.';
					emailTemplate1 += '<BR>TMNAccess shows the Pre-hire was never converted into an Employee after the start date and Pre-hire record is set to be terminated as of  '+Utility.nextBusinessDay(TMNUser.Hire_Date__c,7).format()+'.';	
					emailTemplate1 += ' <BR>If you would like to keep the pre-hire record active in TMNAccess, please take an action on the record in Taleo or TMNAccess. </P>';	
					emailTemplate1 += '<P> If you are not the recruiter for pre-hire mentioned in this email or have other questions, please contact IT Service Center at 888-774-4872 for assistance.</P> <BR/><BR/>';
					emailTemplate1 += '<P>This is an automated message sent by the TMNAccess application. If you have any questions or see any discrepancies in the above information please contact the IT Service Center.</P> ';
					emailTemplate1 += 'Thank you,<BR/> MENTOR IT.';
					mail.setTargetObjectId(recruiterInfo[0].Salesforce_User_Account__c);
					
					String	emailTemplate2 = '<H4> Hello '+TMNUser.Recruiter_Name__c + ', </H4>';
					emailTemplate2 += '<P> You are receiving this message because you are listed as the recruiter for Pre-Hire <B>('+TMNUser.First_Name__c+' '+ TMNUser.Last_Name__c +')</B>  in TMNAccess ';
					emailTemplate2 += 'who was scheduled to start with The Mentor network as of '+TMNUser.Hire_Date__c.format()+'.';
					emailTemplate2 += '<BR>Since no action was taken on the pre-hire record 7 business days after the scheduled start date ('+TMNUser.Hire_Date__c.format()+'), ';	
					emailTemplate2 += 'the record has been terminated in TMNAccess.<BR> This termination would deprovision all the system access provided to the Pre-hire.</P>';
					emailTemplate2 += '<P> If you are not the recruiter for pre-hire mentioned in this email or have other questions, please contact IT Service Center at 888-774-4872 for assistance.</P> <BR/><BR/>';
					emailTemplate2 += '<P>This is an automated message sent by the TMNAccess application. If you have any questions or see any discrepancies in the above information please contact the IT Service Center.</P> ';
					emailTemplate2 += 'Thank you,<BR/> MENTOR IT.';
					
					if(Utility.nextBusinessDay(TMNUser.Hire_Date__c,8) <= currentDate){
					mail.setHtmlBody(emailTemplate2);
					mail.setSubject('***ATTENTION*** TMNAccess – Pre-Hire record terminated');	
					TMNUser.Job_Status__c = 'Inactive';
					} else if((Utility.nextBusinessDay(TMNUser.Hire_Date__c,1) == currentDate) || (Utility.nextBusinessDay(TMNUser.Hire_Date__c,5) == currentDate) || (Utility.nextBusinessDay(TMNUser.Hire_Date__c,7) == currentDate) ){
					mail.setHtmlBody(emailTemplate1);
					mail.setSubject('***TAKE ACTION*** TMNAccess – Pre-Hire termination reminder');
					}
					mail.SaveAsActivity = false;
					mails.add(mail);
					}	
			}
				if(mails.size()>0){
				Messaging.sendEmail(mails);			 
				}
				
				update scope;
	}
			
	
    global void execute(SchedulableContext sc) {
    	Database.executeBatch(new TMNPrehireEmailBatch(), 30);
  }

	global void finish(Database.BatchableContext BC) {

	}			
	

}