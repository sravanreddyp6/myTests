@isTest
private class AdmissionEditExtensionTest {
    static testmethod void simpleTest() {
        /*
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
        Accnt = [
            SELECT ID, PersonContactId FROM Account WHERE ID=:Accnt.ID LIMIT 1
        ];
        System.debug('PersonContactId: ' + Accnt.PersonContactId);
        Admission__c admission = new Admission__c(
            Name='TestName',
            Person_Being_Served__c=Accnt.PersonContactId
        );
        insert admission;
        */
        
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        
        
        PageReference ref = new PageReference('/apex/AdmissionEdit?id='+ myData.theAdm.id);
        Test.setCurrentPage(ref); 
        AdmissionEditExtension controller = new AdmissionEditExtension(new ApexPages.StandardController(myData.theAdm));
        System.assertEquals(myData.theAdm.id, controller.admission.ID);
        controller.admission.Referred_Out_Agency_Name__c = 'Test Agency';
        controller.stdController.save();
        myData.theAdm = [
            SELECT Referred_Out_Agency_Name__c FROM Admission__c
            WHERE ID=:myData.theAdm.id
        ];
        System.assertEquals('Test Agency', myData.theAdm.Referred_Out_Agency_Name__c);
        
        ref = new PageReference('/apex/AdmissionEdit?pbsId='+myData.contactID);
        Test.setCurrentPage(ref);
        controller = new AdmissionEditExtension(new ApexPages.StandardController(New Admission__c()));
        
    }
}