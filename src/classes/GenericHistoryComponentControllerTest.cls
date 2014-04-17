@isTest
public with sharing class GenericHistoryComponentControllerTest {
    static testmethod void simpleTests() {
        String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
        Account Accnt = new Account(
            RecordTypeID=RecTypeId,
            FirstName= 'Test FName',
            LastName='Test LName',
            PersonMailingStreet='test@yahoo.com',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonMailingStateCode='NC',
            PersonEmail='test@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678'
        );
        insert Accnt;
        Accnt = [SELECT Id, PersonContactId FROM Account WHERE Id=:Accnt.Id];
        Admission__c admission = new Admission__c(
            Active__c = false,
            Person_Being_Served__c = Accnt.PersonContactId,
            Name = 'Test Admission'
        );
        insert admission;
        admission.Active__c = true;
        admission.Name = 'Test Admission Updated';
        update admission;

        GenericHistoryComponentController controller = new GenericHistoryComponentController();
        controller.myObject = admission;
        controller.getObjectHistory();
        System.assertEquals('Admission Name', GenericHistoryComponentController.returnFieldLabel('name'));
        GenericHistoryComponentController.objectHistoryLine line =
            new GenericHistoryComponentController.objectHistoryLine();
        System.assertEquals(null, line.theDate);
        System.assertEquals(null, line.who);
        System.assertEquals(null, line.userId);
        System.assertEquals(null, line.action);
    }
}