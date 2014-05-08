@isTest
public class PBSedit_controllerTest{

public static testmethod void testPBSEdit(){



	String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
		Account Accnt = new Account(
			RecordTypeID=RecTypeId,
			FirstName= 'Test FName222222',
			LastName='Test LName2222',
			PersonMailingStreet='10 Main St.',
			PersonMailingPostalCode='12345',
			PersonMailingCity='SF',
			PersonMailingStateCode='CA',
			PersonEmail='test@yahoo.com2222',
			PersonHomePhone='1234567',
			PersonMobilePhone='12345678',
			PersonBirthdate= date.parse('08/01/1980')
		);
		insert Accnt;
		
		Accnt = [select id, personcontactid from account where id = :Accnt.Id];
		Contact pbs = [ select id from contact where id = :Accnt.personcontactId];
		
		PageReference pageRef = Page.PersonBeingServedEditNew;
        Test.setCurrentPageReference(pageRef);
		ApexPages.CurrentPage().getParameters().put('id',pbs.Id);
		ApexPages.CurrentPage().getParameters().put('edit','true');		
		PBSEdit_Controller controller = new PBSEdit_Controller(new ApexPages.StandardController(pbs));
		System.Assert( controller.currentURL.contains('edit') == true);
		
		controller.showAddRelParty();
		
		controller.relParty = PBS_Controller_Helper.saveRelatedParty('', 'test related party', 'Case Manager', 'phone1', '', 
                                              'addr', '', '', '', 'comments', pbs.Id);
                                              
		PBS_Controller_Helper.loadRelatedParty( controller.relParty.Id);
		
		controller.saveRelParty();
		controller.createRelParties();
		
		
		System.Assert( controller.relParties.size() ==1 );
		
		
		controller.cancelPBSController();
		System.Assert( controller.pbsEditModeOn == false );
		
		System.Assert( controller.Attachments.size() == 0 );
		

	}
}