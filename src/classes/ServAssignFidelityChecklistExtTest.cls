@isTest
public with sharing class ServAssignFidelityChecklistExtTest {
    static testmethod void simpleTests() {
    
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
 
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
            Service_Assignment__c = myData.theSA.id,
            Document__c = doc.Id,
            File_Status__c = 'Filed'
        );
        insert jo;

        ServAssignFidelityChecklistExt controller = new ServAssignFidelityChecklistExt(
            new ApexPages.standardController(myData.theSA)
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