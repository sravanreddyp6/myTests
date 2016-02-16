public class PB_RecurringAssocDocsRunBatch implements schedulable {
    public static String query = 'SELECT Id, Document__r.Recurring_Frequency__c, Document__r.Recurring_Interval__c, ' + 
		                        'Due_Date__c, Status__c, Status_Date__c ' + 
		                        'FROM PB_AssociatedDoc__c ' + 
		                        'WHERE (Document__r.Recurring_Frequency__c = \'Recurring\'  OR Document__r.Recurring_Frequency__c = \'As Needed\' )' + 
		                        'AND IsAdded__c = True ' + 
		                        'AND Status__c = \'Received\' ' +
		                        'AND Status_Date__c < TODAY ';
                            
    public void execute(SchedulableContext sc){
        sendBatchStartEmail();
        Database.executeBatch(new PB_RecurringAssocDocs(query));
    }
    
    private void sendBatchStartEmail(){
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<User> userIDs = [SELECT Id FROM User WHERE Name = 'Kate Salines-Johnston'];
        Id userID = userIds[0].Id;
        mail.setTargetObjectId(userID);
        mail.setReplyTo('notifications@thementornetwork.com');
        mail.setSenderDisplayName('ESD Batch Jobs');
        mail.setSubject('Starting Recurring Admission Documents Batch');
        mail.setBccSender(false);
        mail.setUseSignature(false);
                           
        mail.setPlainTextBody(
        'Hello!  The Recurring Admission Documents (PB_RecurringAssocDocsRunBatch.cls) batch job starting....'
        + '/r/n/r/n'
        + 'Datetime of Execution: ' + System.now()
        + '/r/n'
        + 'Thanks!'
        + 'r/n'
        + 'The MENTOR ESD Application'
        );
                
        mail.setHtmlBody(
        'Hello!  The Recurring Admission Documents (PB_RecurringAssocDocsRunBatch.cls) batch job starting....'
        + '<br /><br />'
        + 'Datetime of Execution: ' + System.now()
        + '<br /><br />'
        + 'Thanks!'
        + '<br />'
        + 'The MENTOR ESD Application'
        );
                
        mail.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }

}