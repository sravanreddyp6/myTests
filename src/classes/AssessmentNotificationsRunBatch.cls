public with sharing class AssessmentNotificationsRunBatch implements schedulable {
// CHANGES FOR MINOR RELEASE 3/8/13.  
    public void execute(SchedulableContext sc){
        String query = 'SELECT Id, AccountPerson__c, AccountPerson__r.Id,  AccountPerson__r.PersonContactId, Admission__c, Admission__r.Name, Assessment_Date__c,  CreatedDate, OwnerId, Interval__c, Quarter__c, Assessment_Type__c, Status__c,  Assessment_Type__r.Name, Admission__r.Person_Being_Served__r.Account.LastName, Admission__r.Person_Being_Served__r.Account.FirstName, Owner.LastName, Owner.FirstName, Owner.Email FROM Assessment__c WHERE Assessment_Type_Name__c = \'CANS\' ORDER BY Assessment_Date__c';
        ID batchprocessid = Database.executeBatch(new AssessmentNotifications(query), 5);
    }
}