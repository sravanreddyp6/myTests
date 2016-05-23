@isTest
public with sharing class AttachmentTriggeredActionsTest {
    public static testmethod void simpleTests() {
        Person_Being_Referred__c pbr = new Person_Being_Referred__c();
        insert pbr;
        Referral__c referral = new Referral__c(Person_Being_Referred__c=pbr.Id);
        insert referral;
        RecordType rt = [
            SELECT Id FROM RecordType
            WHERE Name='NeuroRestorative' AND SObjectType='Evaluation__c'
        ];
        Evaluation__c evaluation = new Evaluation__c(
            Referral__c=referral.Id,
            RecordTypeId=rt.Id
        );
        insert evaluation;
        Attachment[] attachments = new Attachment[] {
            new Attachment(
                Name = 'PlanOfCare-04/01/2014.txt',
                Body = Blob.valueOf('Test Body 1'),
                ParentId = referral.Id
            ),
            new Attachment(
                Name = 'PlanOfCare-04/01/2014-1.txt',
                Body = Blob.valueOf('Test Body 2'),
                ParentId = referral.Id
            )
        };
        insert attachments;
        evaluation = [ SELECT Id, Plan_of_Care_Attached__c FROM Evaluation__c WHERE Id=:evaluation.Id ];
        System.assertEquals(true, evaluation.Plan_of_Care_Attached__c);
        delete attachments[0];
        evaluation = [ SELECT Id, Plan_of_Care_Attached__c FROM Evaluation__c WHERE Id=:evaluation.Id ];
        System.assertEquals(true, evaluation.Plan_of_Care_Attached__c);
        delete attachments[1];
        evaluation = [ SELECT Id, Plan_of_Care_Attached__c FROM Evaluation__c WHERE Id=:evaluation.Id ];
        System.assertEquals(false, evaluation.Plan_of_Care_Attached__c);
    }
}