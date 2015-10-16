@isTest
public with sharing class SObjectNotesAndAttachmentTests {
    static testmethod void simpleTests() {
    
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
           
        Note note = new Note(
            ParentId=myData.theAccount.Id,
            Title='Test Note',
            Body='Test Description'
        );
        insert note;
        
        
        Attachment attachment = new Attachment(
            ParentId=myData.theAccount.Id,
            Name='Test Attachment',
            Body=Blob.valueOf('Test Body')
        );
        insert attachment;
        PageReference pageRef = new PageReference('/' + myData.theAccount.Id);
        Test.setCurrentPage(pageRef);
        SObjectNotesAndAttachmentsController con = new SObjectNotesAndAttachmentsController();
        con.parent = myData.theAccount.Id;
        System.assertEquals(2, con.entries.size());
        
        con.toDelete = note.Id;
        con.del();
        System.assertEquals(0, [SELECT ID FROM Note].size());
    }
}