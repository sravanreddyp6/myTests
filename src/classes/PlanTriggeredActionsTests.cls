@isTest
public with sharing class PlanTriggeredActionsTests {
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
        Admission__c adm = new Admission__c(Person_Being_Served__c=Accnt.PersonContactId);
        insert adm;
        Service_Assignment__c sa = new Service_Assignment__c(
            Name = 'TEST SERV ASSIGN',
            Admission__c = adm.Id,
            Person_Being_Served__c = Accnt.PersonContactId,
            Start_Date__c = date.newInstance(2013, 1, 1),
            Status__c = 'Active',
            Program__c = 'IFCS',
            Service_Line__c = 'Intensive In Home - FCT',
            Location_Region__c = 'NC'
        );
        insert sa;
        Plan__c plan = new Plan__c(Admission__c=adm.Id);
        insert plan;
        update plan;
        delete plan;
        undelete plan;
    }
}