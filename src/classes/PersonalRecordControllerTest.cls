@isTest
private class PersonalRecordControllerTest {

    static testMethod void simpleTest() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
     
        PersonalRecordController prc = new PersonalRecordController();
        prc.contactId = myData.contactId;
        System.AssertEquals(0, prc.guardianCount);
        System.AssertEquals( false, prc.hasPhoto);
        System.AssertEquals( prc.con.Id, myData.contactID);
        prc.parentPageName = 'Test Page';
        prc.admissionId = '11111';
        prc.saId = '22222';
        prc.saNew = false;
        
        
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        prc.photo = bodyBlob;
        prc.uploadPhoto( );
            
        
    }
}