public with sharing class DocumentUpdateRunBatch  implements schedulable {
    public void execute(SchedulableContext sc){
        String query = 'SELECT Id, Name, Person_Being_Served__c, Program__c, Location_Region__c, Start_Date__c, End_Date__c, Projected_Treatment_End_Date__c FROM Service_Assignment__c WHERE Status__c = \'Active\' AND RecordType.Name != \'Assessment Only\'';
        ID batchprocessid = Database.executeBatch(new DocumentUpdateBatch(query), 5);
    }
}