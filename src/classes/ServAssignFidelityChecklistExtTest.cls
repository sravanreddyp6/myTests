@isTest
public with sharing class ServAssignFidelityChecklistExtTest {
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

        Admission__c Adm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = Accnt.PersonContactId,
            Effective_Date__c = date.newInstance(2013, 1, 1),
            Status__c = 'Active',
            State__c = 'NC'
        );
        insert Adm;

        Service_Assignment__c sa = new Service_Assignment__c(
            Name = 'TEST SERV ASSIGN',
            Admission__c = Adm.Id,
            Person_Being_Served__c = Accnt.PersonContactId,
            Start_Date__c = date.newInstance(2013, 1, 1),
            Status__c = 'Active',
            Program__c = 'IFCS',
            Service_Line__c = 'Intensive In Home - FCT',
            Phase__c = 1,
            Model__c = 'FCT'
        );
        insert sa;

        Document__c doc = new Document__c(
            Type__c = 'Fidelity Document',
            Order__c = 1,
            Phase_or_Level__c = 1,
            state__c = 'NC'
        );
        insert doc;

        Program_Document_Xref__c progDoc = new Program_Document_Xref__c(
            Document__c = doc.Id,
            Program__c = 'IFCS',
            Service_Line__c = 'Intensive In Home - FCT'
        );
        insert progDoc;

        ServiceAssignment_Document_JO__c jo = new ServiceAssignment_Document_JO__c(
            Service_Assignment__c = sa.Id,
            Document__c = doc.Id,
            File_Status__c = 'Filed'
        );
        insert jo;

        ServAssignFidelityChecklistExt controller = new ServAssignFidelityChecklistExt(
            new ApexPages.standardController(sa)
        );
        controller.findFidelityDocs();
        controller.listOfFidDocFilings[0].selectFidDocStatusBeforeSave = false;
        controller.saveFidDocSelections();
        controller.refreshListOfDocFilings();
        System.assert(ServAssignFidelityChecklistExt.loadSadjo(jo.Id) != null);
        ServAssignFidelityChecklistExt.saveSadjoRemote(jo.Id, 'Test NA Reason',
            'Test Status', true);
        controller.addError('Test Error');
    }
}