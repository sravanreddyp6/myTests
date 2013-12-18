@isTest
private class AdmissionViewExtensionTest {
	static testmethod void simpleTest() {
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

		PageReference ref = new PageReference('/apex/AdmissionView?id='+admission.ID);
		Test.setCurrentPage(ref); 
		AdmissionViewExtension controller = new AdmissionViewExtension(new ApexPages.StandardController(admission));
		// The controller really doesn't do anything other than fetching the
		// record, so we just check to make sure the record is fetch correctly
		System.assertEquals(admission.ID, controller.admission.ID);
	}
}