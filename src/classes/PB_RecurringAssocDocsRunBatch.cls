public class PB_RecurringAssocDocsRunBatch implements schedulable {
    
    public void execute(SchedulableContext sc){
        String query = 'SELECT Id, Document__r.Recurring_Frequency__c, Document__r.Recurring_Interval__c, ' + 
                        'Due_Date__c, Status__c, Status_Date__c ' + 
                        'FROM PB_AssociatedDoc__c ' + 
                        'WHERE Document__r.Recurring_Frequency__c = \'Recurring\' ' + 
                        'AND IsAdded__c = True ' + 
                        'AND Status__c = \'Received\' ' +
                        'AND Status_Date__c < TODAY ';
        Database.executeBatch(new PB_RecurringAssocDocs(query));
        
    }

}