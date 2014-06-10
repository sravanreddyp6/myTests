global class DocumentUpdateBatch implements Database.Batchable<sObject> {
   global final String Query;

   global DocumentUpdateBatch(String q) {
             Query=q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator(Query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope) {
   	  List<sObject> scopeClone = scope.clone(); 
      Service_Assignment__c[] srvAsnsFromScope = (Service_Assignment__c[])scope; 
   	 
   	 DocumentMethods.docPop(srvAsnsFromScope,'updateAll');
   	 DocumentMethods.docPop(srvAsnsFromScope,true);
   }
   
   global void finish(Database.BatchableContext BC) {
                Messaging.reserveSingleEmailCapacity(1);       
                
                // Processes and actions involved in the Apex transaction occur next, 
                // which conclude with sending a single email. 
                    
                // Now create a new single email message object 
                // that will send out a single email to the addresses in the To, CC & BCC list. 
                    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         
                
                // Get user Id of this script's author.  Assumes we'll only have one person with this full name.
                // If changed to a more common name, recode for that.               
                List<User> userIDs = [SELECT Id FROM User WHERE Name = 'Josh Gilliam'];     
                Id userID = userIds[0].Id;
                
                // Set receiver of email "target" to the User Id of the script author.
                mail.setTargetObjectId(userID);
                
                // Specify the address used when the recipients reply to the email.                 
                mail.setReplyTo('notifications@thementornetwork.com');
         
                // Specify the name used as the display name.      
                mail.setSenderDisplayName('Case Document Batch Confirmation');
         
                // Specify the subject line the your email.      
                mail.setSubject('Case Document Batch Confirmation');
                         
                // Set to True if you want to BCC yourself on the email.    
                mail.setBccSender(false);
                          
                // Optionally append the salesforce.com email signature to the email. 
                // The email address of the user executing the Apex Code will be used.             
                mail.setUseSignature(false);
                           
                // Specify the text content of the email.                     
                mail.setPlainTextBody(
                'Hello!  The DocumentUpdateBatch.cls batch job ran.'
                + '/r/n/r/n'
                + 'Datetime of Execution: ' + System.now()
                + '/r/n'
                + 'Thanks!'
                + 'r/n'
                + 'The MENTOR ESD Application'
                );
                
                mail.setHtmlBody(
                'Hello!  The DocumentUpdateBatch.cls batch job ran.'
                + '<br /><br />'
                + 'Datetime of Execution: ' + System.now()
                + '<br /><br />'
                + 'Thanks!'
                + '<br />'
                + 'The MENTOR ESD Application'
                );
                
                mail.setSaveAsActivity(false);
                
                // Send the email you have created. 
                if (!Test.IsRunningTest())    
                	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   	
   }
   
}