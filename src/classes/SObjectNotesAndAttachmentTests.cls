@isTest
public with sharing class SObjectNotesAndAttachmentTests {
    static testmethod void simpleTests() {
        String RecTypeId = [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
        Account acct = new Account(
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
        insert acct;
        Note note = new Note(
            ParentId=acct.ID,
            Title='Test Note',
            Body='Test Description'
        );
        insert note;
        Attachment attachment = new Attachment(
            ParentId=acct.Id,
            Name='Test Attachment',
            Body=Blob.valueOf('Test Body')
        );
        insert attachment;
        PageReference pageRef = new PageReference('/' + acct.Id);
        Test.setCurrentPage(pageRef);
        SObjectNotesAndAttachmentsController con = new SObjectNotesAndAttachmentsController();
        con.parent = acct.Id;
        System.assertEquals(2, con.entries.size());
        
        con.toDelete = note.Id;
        con.del();
        System.assertEquals(0, [SELECT ID FROM Note].size());
    }
}