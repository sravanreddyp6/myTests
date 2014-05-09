@isTest
private class PersonalRecordControllerTest {

    static testMethod void simpleTest() {
        String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
        Account Accnt = new Account(
            RecordTypeID=RecTypeId,
            FirstName= 'Test FName again',
            LastName='Test LName',
            PersonMailingStreet='test@yahoo.com11111',
            PersonMailingPostalCode='12345',
            PersonMailingCity='Raleigh',
            PersonMailingStateCode='NC',
            PersonEmail='test@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678'
        );
        insert Accnt;
        Accnt = [
            SELECT ID, PersonContactId FROM Account WHERE ID=:Accnt.ID LIMIT 1
        ];
        
        PersonalRecordController prc = new PersonalRecordController();
        prc.contactId = Accnt.PersonContactId;
        System.AssertEquals(0, prc.guardianCount);
        System.AssertEquals( false, prc.hasPhoto);
        System.AssertEquals( prc.con.Id, Accnt.PersonContactId);
        prc.parentPageName = 'Test Page';
        prc.admissionId = '11111';
        prc.saId = '22222';
        prc.saNew = false;
        
        
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        prc.photo = bodyBlob;
    	prc.uploadPhoto( );
   	
    	
        
    }
}