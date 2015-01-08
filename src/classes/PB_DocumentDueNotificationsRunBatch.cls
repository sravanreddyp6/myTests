public class PB_DocumentDueNotificationsRunBatch implements schedulable {
	
    public void execute(SchedulableContext sc){
        // get all the associated docs that are past due or due in next 7 and not yet Received
        String query = 'SELECT Id, Document__r.Document_Name__c, Due_Date__c, IsAdded__c, ' + 
                        'sObject_Id__c, sObject_Type__c, Status__c, Status_Date__c ' + 
                        'FROM PB_AssociatedDoc__c ' + 
                        'WHERE Status__c != \'Received\' ' + 
                        'AND IsAdded__c = True ' + 
                        'AND Due_Date__c < NEXT_N_DAYS:7';
        Database.executeBatch(new PB_DocumentDueNotifications(query));
        
    }

}