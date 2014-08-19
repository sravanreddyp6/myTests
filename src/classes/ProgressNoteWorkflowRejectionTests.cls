@isTest
public with sharing class ProgressNoteWorkflowRejectionTests {
    static testmethod void simpleTests() {
        Contact c = new Contact(LastName = 'Last');
        insert c;
        Progress_Note__c pn = new Progress_Note__c(
            Person_Being_Served__c = c.Id,
            Start_Time__c = DateTime.now().addMinutes(-1),
            End_Time__c = DateTime.now(),
            Signature_on_File__c = 'Y',
            Approval_Status__c = 'Pending'
        );
        insert pn;
        pn.Approval_Status__c = 'Needs Refinement';
        update pn;
        pn = [
            SELECT Id, Signature_on_File__c FROM Progress_Note__c WHERE Id=:pn.Id
        ];
        System.assertEquals('N', pn.Signature_on_File__c);
    }
}