global class ProgressNoteNotifications implements Database.Batchable<sObject> {

   global final String Query;

   global ProgressNoteNotifications(String q){
             Query=q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(Query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
  
	List<sObject> scopeClone = scope.clone();   
	  
	Progress_Note__c[] pnsFromScope = (Progress_Note__c[])scope; 
	List<Messaging.SingleEmailMessage> noticeEmails = new List<Messaging.SingleEmailMessage>();
	
	  
	for(Progress_Note__c pN : pnsFromScope) {
		System.debug('date.today(): ' + date.today());
		System.debug('(pn.CreatedDate + 3).date(): ' + (pn.CreatedDate + 3).date());
		if(Test.isRunningTest()==true) {
			if(date.today().isSameDay(pn.CreatedDate.date())==true) {
				noticeEmails.add(sendNotification(pN));		
			}
		}
		else {
			if(date.today()>(pn.CreatedDate + 1).date()) {
				noticeEmails.add(sendNotification(pN));
			}
		}
  	}               
    Messaging.sendEmail(noticeEmails);      
   }
   
 
   private Messaging.SingleEmailMessage sendNotification(Progress_Note__c pN){
    
    try {
    	
    		Date dueDate = (pN.CreatedDate + 7).date();

                // Reserve email capacity for the current Apex transaction to ensure 
                // that we won't exceed our daily email limits when sending email after 
                // the current transaction is committed. 
                Messaging.reserveSingleEmailCapacity(1);
         
                
                // Processes and actions involved in the Apex transaction occur next, 
                // which conclude with sending a list of emails. 
                    
                // Now create a new single email message object 
                // that will send out a single email to the addresses in the To, CC & BCC list.          
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                // Set receiver of email to a User Id for a Salesforce user; the owner of the assessment for
                // which we are sending a notification.  
                mail.setTargetObjectId(pN.OwnerId);        
                      
                // Specify the address used when the recipients reply to the email.                 
                mail.setReplyTo('notifications@thementornetwork.com');
         
                
                // Specify the name used as the display name.      
                mail.setSenderDisplayName('MENTOR Progress Note Notification');
         
                
                // Specify the subject line for the email.      
                mail.setSubject('Notification from the MENTOR Salesforce ESD App');
                    
                // Set to True if you want to BCC yourself on the email.    
                mail.setBccSender(false);
                        
                // Optionally append the salesforce.com email signature to the email. 
                // The email address of the user executing the Apex Code will be used.             
                mail.setUseSignature(false);
           
                
                // Specify the text content of the email. 
                    
                mail.setPlainTextBody('Hello ' 
                    + pN.Owner.FirstName + ' ' + pN.Owner.LastName 
                    + ',/r/n/r/nA Progress Note that you own has a non-final status one day or more after creation (Created Date: '
                    + pN.CreatedDate.format('M/d/yy')
                    + ').  Please review the note and finalize it ASAP.  Go to the following webpage to access the note:  ' 
                    + System.Url.getSalesforceBaseUrl().toExternalForm()
                    + '/'
                    + pN.Id
                    +'/r/n/r/nThanks!/r/nThe MENTOR Salesforce ESD App');
                
                mail.setHtmlBody('Hello ' 
                    + pN.Owner.FirstName + ' ' + pN.Owner.LastName 
                    + ',<br /><br />A Progress Note that you own has a non-final status one day or more after creation (Created Date: '
                    + pN.CreatedDate.format('M/d/yy')
                    + ').  Please review the note and finalize it ASAP.  '
                    + '<a href="'
                    + System.Url.getSalesforceBaseUrl().toExternalForm()
                    + '/'
                    + pN.Id
                    + '">'
                    + 'Click here to access the note.'
                    + '</a>'
                    +'<br /><br />Thanks!<br />The MENTOR Salesforce ESD App');
                
                
                mail.setSaveAsActivity(false);

            
                // Create a task reminder for the action.
                Task t = new Task(Subject = 'Progress Note Reminder', Status = 'In Progress', Priority = 'Normal', OwnerId = pN.OwnerId, Description = 'You have a Progress Note that appears to be in a non-final state one day or more after creation (Created Date: ' + pN.CreatedDate.format('M/d/yy') + ').  Please review the note and finalize it ASAP: ' + System.Url.getSalesforceBaseUrl().toExternalForm() + '/' + pN.Id, WhoId = pN.Person_Being_Served__c, WhatId = pN.Person_Being_Served__r.Account.Id, ActivityDate = dueDate);
                insert t;
                
                return mail;
        }
        catch(Exception e){

	                // Reserve email capacity for the current Apex transaction to ensure 
	                // that we won't exceed our daily email limits when sending email after 
	                // the current transaction is committed. 
	                Messaging.reserveSingleEmailCapacity(1);
	         
	                
	                // Processes and actions involved in the Apex transaction occur next, 
	                // which conclude with sending a list of emails. 
	                    
	                // Now create a new single email message object 
	                // that will send out a single email to the addresses in the To, CC & BCC list.          
	                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	                
	                // Set receiver of email to a User Id for a Salesforce user; the owner of the assessment for
	                // which we are sending a notification.  
	                
	                User idForAssmtDeveloper = [ SELECT Id FROM User WHERE LastName = 'integration' LIMIT 1];
	                
	                mail.setTargetObjectId(idForAssmtDeveloper.Id);            
	                      
	                // Specify the address used when the recipients reply to the email.                 
	                mail.setReplyTo('notifications@thementornetwork.com');
	         
	                
	                // Specify the name used as the display name.      
	                mail.setSenderDisplayName('FAILURE: MENTOR Progress Note Notification');
	         
	                
	                // Specify the subject line for the email.      
	                mail.setSubject('FAILURE: MENTOR Progress Note Notification');
	                    
	                // Set to True if you want to BCC yourself on the email.    
	                mail.setBccSender(false);
	                        
	                // Optionally append the salesforce.com email signature to the email. 
	                // The email address of the user executing the Apex Code will be used.             
	                mail.setUseSignature(false);
	           
	                
	                // Specify the text content of the email. 
	                    
	                mail.setPlainTextBody('Hello!' 
	                    + '/r/n/r/nA progress note notification to '
	                    + + pN.Owner.FirstName + ' ' + pN.Owner.LastName 
	                    + ' failed.  The intended message follows:  /r/n/r/n'
						+ 'Hello ' 
	                    + pN.Owner.FirstName + ' ' + pN.Owner.LastName 
	                    + ',/r/n/r/nA Progress Note that you own has a non-final status one day or more after creation (Created Date: '
                    	+ pN.CreatedDate.format('M/d/yy')
                    	+ ').  Please review the note and finalize it ASAP.  Go to the following webpage to access the note: ' 
	                    + System.Url.getSalesforceBaseUrl().toExternalForm()
	                    + '/'
	                    + pN.Id
	                    +'/r/n/r/nThanks!/r/nThe MENTOR Salesforce ESD App');
	                
	                mail.setHtmlBody('Hello!'
	                	+ '/r/n/r/nA progress note notification to ' 
	                    + pN.Owner.FirstName + ' ' + pN.Owner.LastName
	                    + ' failed.  The intended message follows:  <br /><br />'
						+ 'Hello ' 
	                    + pN.Owner.FirstName + ' ' + pN.Owner.LastName 
	                    + ',<br /><br />A Progress Note that you own has a non-final status one day or more after creation (Created Date: '
                    	+ pN.CreatedDate.format('M/d/yy')
                    	+ ').  Please review the note and finalize it ASAP:  '
	                    + '<a href="'
	                    + System.Url.getSalesforceBaseUrl().toExternalForm()
	                    + '/'
	                    + pN.Id
	                    + '">'
	                    + 'Click here to access the note.'
	                    +'</a>'
	                    +'<br /><br />Thanks!<br />The MENTOR Salesforce ESD App');
	                
	                
	                mail.setSaveAsActivity(false);
	                
	                // Send the email you have created.
	                // PLEASE NOTE:  It is IMPORTANT that we use this method of making one call to regularNoticeEmails.add()
	                // because there is a limit on the number of email calls that can be made per execution of the batch.
	                // I believe that limit is 10 calls.  Calling the method ONCE for a list of single emails only counts
	                // as one call, but gets multiple messages sent.
	                List<Messaging.SingleEmailMessage> regularNoticeEmails = new List<Messaging.SingleEmailMessage>();
	                regularNoticeEmails.add(mail);
	                
	                User idForBP = [ SELECT Id FROM User WHERE FirstName = 'Michelle' AND LastName = 'Broadbent' LIMIT 1];
	                mail.setTargetObjectId(idForBP.Id);	            
	                
	                return mail;
	                
        }       
                
            
   }


   global void finish(Database.BatchableContext BC){
                Messaging.reserveSingleEmailCapacity(1);
         
                
                // Processes and actions involved in the Apex transaction occur next, 
                // which conclude with sending a single email. 
                    
                // Now create a new single email message object 
                // that will send out a single email to the addresses in the To, CC & BCC list. 
                    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         
                
                // Get user Id of this script's author.  Assumes we'll only have one person with this full name.
                // If changed to a more common name, recode for that.               
                List<User> userIDs = [SELECT Id FROM User WHERE Name = 'integration'];     
                Id userID = userIds[0].Id;
                
                // Set receiver of email "target" to the User Id of the script author.
                mail.setTargetObjectId(userID);
                
                // Specify the address used when the recipients reply to the email.                 
                mail.setReplyTo('notifications@thementornetwork.com');
         
                // Specify the name used as the display name.      
                mail.setSenderDisplayName('Progress Note Notification Batch Confirmation');
         
                // Specify the subject line the your email.      
                mail.setSubject('Progress Note Notification Batch Confirmation');
                         
                // Set to True if you want to BCC yourself on the email.    
                mail.setBccSender(false);
                          
                // Optionally append the salesforce.com email signature to the email. 
                // The email address of the user executing the Apex Code will be used.             
                mail.setUseSignature(false);
                           
                // Specify the text content of the email.                     
                mail.setPlainTextBody(
                'Hello!  The ProgressNoteNotifications.cls batch job ran.'
                + '/r/n/r/n'
                + 'Datetime of Execution: ' + System.now()
                + '/r/n'
                + 'Thanks!'
                + 'r/n'
                + 'The MENTOR ESD Assessment Application'
                );
                
                mail.setHtmlBody(
                'Hello!  The The ProgressNoteNotifications.cls batch job ran.'
                + '<br /><br />'
                + 'Datetime of Execution: ' + System.now()
                + '<br /><br />'
                + 'Thanks!'
                + '<br />'
                + 'The MENTOR ESD Assessment Application'
                );
                
                mail.setSaveAsActivity(false);
                
                // Send the email you have created. 
                    
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }
  
}