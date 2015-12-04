@isTest
public with sharing class attachPDFTEST {
static testMethod void myUnitTest() {


    // create a new note and supporting info
    Contact testContact = new Contact(
            LastName = 'TestLastName'
        );
        insert testContact;
        
        Admission__c testAdm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = testContact.Id,
            Effective_Date__c = date.today()
        );
        insert testAdm;
        
        Service_Assignment__c testServAssignment = new Service_Assignment__c(
            Admission__c = testAdm.Id,
            Person_Being_Served__c = testContact.Id
        );
        insert testServAssignment;
        
        Service_Code__c testServCode = new Service_Code__c(
            Service_Code__c = 'TEST SVC CODE',
            FacilityID__c = 'TEST FAC ID',
            Program_Code__c = 'TEST PROGRAM CODE',
            start_Date__c = date.newinstance( 2012, 1, 1)
        );
        insert testServCode;
        
        Progress_Note__c testPN = new Progress_Note__c(
            Service_Assignment__c = testServAssignment.Id, 
            Service_Code__c = testServCode.Id, 
            Admission__c = testAdm.ID,
            Start_Time__c = datetime.newInstance(2012, 1, 1, 13, 0, 0),
            End_Time__c = datetime.newInstance(2012, 1, 1, 15, 0, 0),
            Person_Being_Served__c = testContact.Id,
            No_Approval_Needed__c = true,
            Approval_Status__c = 'Approved',
            Status__c = 'Final',
            Number_of_Required_Signatures__c = 1
        );
        insert testPN;
        
        testPN = [select id, signature_required__c, signature_on_file__c from Progress_Note__c where id= :testPN.Id];
        System.AssertEquals( testPN.signature_required__c, 'Y');
        
        // use a blob for the image data to post
        Blob b = Blob.valueOf('Test Data');  
        
        // encode it
        String strImg = EncodingUtil.base64Encode(b);
        
        PageReference pageRef = Page.Notes_PRogressNote_AjaxPostback;
        
        ApexPages.currentPage().getParameters().put('id', testPN.Id);
        ApexPages.currentPage().getParameters().put('img',strImg);
        
        attachPDF controller = new attachPDF();
        controller.myId = testPN.Id;
        controller.strImg = strImg;
        
        controller.upload();
        
        testPN = [select id, signature_required__c, signature_on_file__c from Progress_Note__c where id= :testPN.Id];
        
        System.AssertEquals(testPN.signature_on_file__c, 'Y' );
        
}

}