public class PB_DocumentDueNotificationsRunBatch implements schedulable {
    // get all the associated docs that are past due or due in next 7 and not yet Received
    public static String query = 'SELECT Id, Document__r.Document_Name__c, Due_Date__c, IsAdded__c, ' + 
                        'sObject_Id__c, sObject_Type__c, Status__c, Status_Date__c ' + 
                        'FROM PB_AssociatedDoc__c ' + 
                        'WHERE Status__c != \'Received\' ' + 
                        'AND IsAdded__c = True ' + 
                        'AND Due_Date__c <= NEXT_N_DAYS:7';	
    public void execute(SchedulableContext sc){
        sendBatchStartEmail();
        Database.executeBatch(new PB_DocumentDueNotifications(query));
    }

    private void sendBatchStartEmail(){
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<User> userIDs = [SELECT Id FROM User WHERE Name = 'Kate Salines-Johnston'];
        Id userID = userIds[0].Id;
        mail.setTargetObjectId(userID);
        mail.setReplyTo('notifications@thementornetwork.com');
        mail.setSenderDisplayName('ESD Batch Jobs');
        mail.setSubject('Starting Admission Document Due Batch');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        
        mail.setPlainTextBody(
                'Hello!  The Admission Document Due Notifications (PB_DocumentDueNotificationsRunBatch.cls) batch job starting....'
                + '/r/n/r/n'
                + 'Datetime of Execution: ' + System.now()
                + '/r/n'
                + 'Thanks!'
                + 'r/n'
                + 'The MENTOR ESD Application'
                );
                
        mail.setHtmlBody(
                'Hello!  The Admission Document Due Notifications (PB_DocumentDueNotificationsRunBatch.cls) batch job starting....'
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