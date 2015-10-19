global class HIPPAReport implements Database.Batchable<sObject> {
	
 global String manageIds = '';
 global List<TMN_User__c> tmnUsers; 
 global list<Task> taskToInsert;
   global String query = '';  
   global HIPPAReport() {
   	tmnUsers = new List<TMN_User__c>();
    	 taskToInsert = new list<Task>();
   }

   global Database.QueryLocator start(Database.BatchableContext BC) {
   			query =	'SELECT Name,Email__c,Manager_Name__c,First_Name__c,Last_Name__c,Preferred_First_Name__c,Salesforce_User_Account__c  FROM TMN_User__c limit 1';
       			return  Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope) {
   	  						list<AggregateResult> userAggregateResult = [select Manager_Email__c from TMN_User__c where  manager_email__c <> '' and Alias__c= '001140' group by Manager_Email__c ];
   					for(integer i=0;i<userAggregateResult.size()-1;i++) {
   					manageIds += '\''+ string.valueof(userAggregateResult[i].get('Manager_Email__c')) + '\',';
   					}
   					manageIds += '\''+ string.valueof(userAggregateResult[userAggregateResult.size()-1].get('Manager_Email__c')) + '\'';
   			System.debug('manageIds  '+ manageIds);	
   		 	query  = 'SELECT Name,Email__c,Manager_Name__c,First_Name__c,Last_Name__c,Preferred_First_Name__c,Salesforce_User_Account__c  FROM TMN_User__c where';  
   			     query  +=' Salesforce_User_Account__r.isActive= true and  Alias__c= \'001140\' and  email__c in  (' +manageIds + ')';	
       List<Messaging.SingleEmailMessage> mails =   new List<Messaging.SingleEmailMessage>();
   					tmnUsers = Database.query(query);
   					for(TMN_User__c tmn:tmnUsers) {
   					Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
            		mail.setTargetObjectId(tmn.Salesforce_User_Account__c);
         			mail.setSubject('Quarterly Event Log Report');
         			String body = 'Quarterly Event Log Report for '+tmn.name+' .';
         			mail.setHtmlBody(body);
         			//mail.setWhatId(tmn.Salesforce_User_Account__c);
                    mail.SaveAsActivity = false;    
         			mails.add(mail);
         			taskToInsert.add(new Task(Subject = 'Quarterly Event Log Report', Status = 'Not Approved', Priority = 'High', 
	        	                           OwnerId = tmn.Salesforce_User_Account__c,
	        	                           Description = 'Quarterly Event Log Report for ' + tmn.First_Name__c + ' ' + tmn.Last_Name__c, 
	        	                           WhatId = tmn.Id, ActivityDate = Date.Today() )) ;
	        	                           
   					}
   
       insert taskToInsert;
   Messaging.sendEmail(mails);
   System.debug('Total Number of Emails and Tasks ' + mails.size());
   }
   
   global void finish(Database.BatchableContext BC) {
   
   }
   
	

}