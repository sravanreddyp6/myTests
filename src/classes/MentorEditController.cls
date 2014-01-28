public with sharing class MentorEditController {
    public TMN_Contact__c contact;

    public MentorEditController(ApexPages.standardController stdController) {
        contact = (TMN_Contact__c) stdController.getRecord();
        contact.RecordTypeId = [
            SELECT Id FROM RecordType WHERE SObjectType = 'TMN_Contact__c'
            AND Name = 'Mentor'
        ].Id;
    }
}