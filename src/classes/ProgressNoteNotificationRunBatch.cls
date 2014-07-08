public class ProgressNoteNotificationRunBatch implements schedulable {
    public void execute(SchedulableContext sc){
        String query = 'SELECT Id, OwnerId, Owner.FirstName, Owner.LastName, CreatedDate, Person_Being_Served__c, Person_Being_Served__r.Account.Id FROM Progress_Note__c WHERE Status__c != \'Final\' AND RecordType.Name != \'Shift Note\' AND CreatedDate >= 2013-12-27T00:00:00Z and Admission_State__c != \'AZ\' And Disregard_Note__c = False';
        ID batchprocessid = Database.executeBatch(new ProgressNoteNotifications(query), 50);
    }
}