public class ProgressNoteNotificationRunBatch {
    public void execute(SchedulableContext sc){
        String query = 'SELECT Id, OwnerId, Owner.FirstName, Owner.LastName, CreatedDate, Person_Being_Served__c, Person_Being_Served__r.Account.Id FROM Progress_Note__c WHERE Status__c != \'Final\'';
        ID batchprocessid = Database.executeBatch(new ProgressNoteNotifications(query), 50);
    }
}