global class PB_RecurringAssocDocs implements Database.Batchable<sObject> {
   global final String query;

    global PB_RecurringAssocDocs(String q){
            query=q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<PB_AssociatedDoc__c> scope){
        sendBatchStartEmail();
 
        List<PB_AssocDocRecurrence__c> recurrs = new List<PB_AssocDocRecurrence__c>();
        for(PB_AssociatedDoc__c assocDoc : scope){
        	
        	recurrs.add(new PB_AssocDocRecurrence__c(PB_AssociatedDoc__c = assocDoc.id,
                                                     Status__c = assocDoc.Status__c,
                                                     Status_Date__c = assocDoc.Status_Date__c));
            assocDoc.Due_Date__c = getDueDate(assocDoc.Status_Date__c, assocDoc.Document__r.Recurring_Interval__c);
            assocDoc.Status__c = 'Pending';
            assocDoc.Status_Date__c = Null;            
        }

        insert recurrs;
        update scope;
    }
   
    private Date getDueDate(Date dueDate, String recurr){
        system.debug('getDueDate inputs: ' + dueDate + '  ' + recurr);
        Date recurrDueDate;
        if (recurr == 'Annually')  recurrDueDate = dueDate.addYears(1); 
        else if (recurr == 'Monthly') recurrDueDate = dueDate.addMonths(1);
        else if (recurr == 'Quarterly') recurrDueDate = dueDate.addMonths(3);
        return recurrDueDate;
    }
    
    global void finish(Database.BatchableContext BC){
        Messaging.reserveSingleEmailCapacity(1);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                List<User> userIDs = [SELECT Id FROM User WHERE Name = 'Neeraj Gupta'];
                Id userID = userIds[0].Id;
                
                // Set receiver of email "target" to the User Id of the script author.
                mail.setTargetObjectId(userID);
                
                // Specify the address used when the recipients reply to the email.                 
                mail.setReplyTo('notifications@thementornetwork.com');
         
                // Specify the name used as the display name.      
                mail.setSenderDisplayName('ESD Batch Jobs');
         
                // Specify the subject line the your email.      
                mail.setSubject('Recurring Admission Documents Batch Confirmation');
                         
                // Set to True if you want to BCC yourself on the email.    
                mail.setBccSender(false);
                          
                // Optionally append the salesforce.com email signature to the email. 
                // The email address of the user executing the Apex Code will be used.             
                mail.setUseSignature(false);
                           
                // Specify the text content of the email.                     
                mail.setPlainTextBody(
                'Hello!  The Recurring Admission Documents (PB_RecurringAssocDocs.cls) batch job ran.  '
                + '/r/n/r/n'
                + 'Datetime of Execution: ' + System.now()
                + '/r/n'
                + 'Thanks!'
                + 'r/n'
                + 'The MENTOR ESD Application'
                );
                
                mail.setHtmlBody(
                'Hello!  The Recurring Admission Documents (PB_RecurringAssocDocs.cls) batch job ran.  '
                + '<br /><br />'
                + 'Datetime of Execution: ' + System.now()
                + '<br /><br />'
                + 'Thanks!'
                + '<br />'
                + 'The MENTOR ESD Application'
                );
                
                mail.setSaveAsActivity(false);
                
                // Send the email you have created. 
                    
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }
   
       private void sendBatchStartEmail(){
                Messaging.reserveSingleEmailCapacity(1);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
                List<User> userIDs = [SELECT Id FROM User WHERE Name = 'Neeraj Gupta'];
                Id userID = userIds[0].Id;
                
                // Set receiver of email "target" to the User Id of the script author.
                mail.setTargetObjectId(userID);
                
                // Specify the address used when the recipients reply to the email.                 
                mail.setReplyTo('notifications@thementornetwork.com');
         
                // Specify the name used as the display name.      
                mail.setSenderDisplayName('ESD Batch Jobs');
         
                // Specify the subject line the your email.      
                mail.setSubject('Starting Recurring Admission Documents Batch');
                         
                // Set to True if you want to BCC yourself on the email.    
                mail.setBccSender(false);
                          
                // Optionally append the salesforce.com email signature to the email. 
                // The email address of the user executing the Apex Code will be used.             
                mail.setUseSignature(false);
                           
                // Specify the text content of the email.                     
                mail.setPlainTextBody(
                'Hello!  The Recurring Admission Documents (PB_RecurringAssocDocs.cls) batch job starting....'
                + '/r/n/r/n'
                + 'Datetime of Execution: ' + System.now()
                + '/r/n'
                + 'Thanks!'
                + 'r/n'
                + 'The MENTOR ESD Application'
                );
                
                mail.setHtmlBody(
                'Hello!  The Recurring Admission Documents (PB_RecurringAssocDocs.cls) batch job starting....'
                + '<br /><br />'
                + 'Datetime of Execution: ' + System.now()
                + '<br /><br />'
                + 'Thanks!'
                + '<br />'
                + 'The MENTOR ESD Application'
                );
                
                mail.setSaveAsActivity(false);
                
                // Send the email you have created. 
                    
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }
}