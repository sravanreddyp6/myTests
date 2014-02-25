@isTest
private class PBS_ControllerTest {

    static testMethod void insertPBSTest() {
        String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
		Account Accnt = new Account(
			RecordTypeID=RecTypeId,
			FirstName= 'Test FName',
			LastName='Test LName',
			PersonMailingStreet='10 Main St.',
			PersonMailingPostalCode='12345',
			PersonMailingCity='SF',
			PersonMailingStateCode='CA',
			PersonEmail='test@yahoo.com',
			PersonHomePhone='1234567',
			PersonMobilePhone='12345678',
			PersonBirthdate= date.parse('08/01/2000')
		);
		
		Related_Party__c relParty = new Related_Party__c ( Name='rp name', type__c = 'Guardian');
		
		PageReference ref = new PageReference('/apex/PBS_Create');
		Test.setCurrentPage(ref); 
		
		PBS_Controller controller = new PBS_Controller(new ApexPages.StandardController(Accnt));
		
		PageReference ref2;
		try {
			ref2 = controller.savePBS();
			List<ApexPages.Message> msgList = ApexPages.getMessages();
			for(ApexPages.Message msg :  ApexPages.getMessages()) {
				system.debug( msg.getSummary());
    			System.Assert(msg.getSummary().contains ('younger than 18'));
    			System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
			}			
			
		
		} catch (Exception e) {
			// person is less than 18 and no guardian provided; should throw error
			System.Assert( e.getMessage().contains('less than 18'), e.getMessage() );
		}
		controller.relParty = relParty;
		ref2 = controller.savePBS();

		
		Related_Party__c rp = PBS_controller_helper.loadRelatedParty(relParty.Id);
		System.assertEquals( relParty.name, rp.name);
		
		rp = PBS_controller_helper.saveRelatedParty(rp.Id, 'rp new name', rp.type__c, '', '', '', '', '', '', '',
									'','','','','', controller.pBSId);
		Related_Party__c rp2 = PBS_controller_helper.saveRelatedParty(null, 'another rp', rp.type__c, '', '', '', '', '', '', '', 
									'','','','','', controller.pBSId);
		System.assertEquals( rp.type__c, rp2.type__c);
		
		
		Account Accnt2 = new Account(
			RecordTypeID=RecTypeId,
			FirstName= 'Test FName',
			LastName='Test LName',
			PersonMailingStreet='10 Main St.',
			PersonMailingPostalCode='12345',
			PersonMailingCity='SF',
			PersonMailingStateCode='CA',
			PersonEmail='test@yahoo.com',
			PersonHomePhone='1234567',
			PersonMobilePhone='12345678',
			PersonBirthdate= date.parse('08/01/2000')
		);

		controller = new PBS_Controller(new ApexPages.StandardController(Accnt2));
		Related_Party__c relParty2 = new Related_Party__c ( Name='rp name', type__c = 'Guardian');
		
		try {
			controller.relParty = relParty2;
			ref2 = controller.savePBS();
			List<ApexPages.Message> msgList = ApexPages.getMessages();
			for(ApexPages.Message msg :  ApexPages.getMessages()) {
				system.debug( msg.getSummary());
    			System.Assert(msg.getSummary().contains ('already exists') || msg.getSummary().contains('guardian'));
    			System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
			}
		} catch (Exception e) {
			// person is duplicate; should throw error
			System.Assert( e.getMessage().contains('already exists'), e.getMessage() );
		}
		
		System.assertEquals( false, PBS_controller_helper.isUserLevel1or2());
		
    }
}