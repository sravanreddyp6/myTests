/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CredentialAddTEST {

    static testMethod void myUnitTest() {
    	
    	Credential_Profile__c HealthInspection_Profile = new Credential_Profile__c(
        	Name = 'Health Inspection',
        	Required_for_Mentor__c = true,
        	OLM_Requirement__c = true,
        	Applies_Requested_Date__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_Documented_Date__c = true,
        	DHR_Scope__c = 'Household',
        	Section__c = 'Test',
        	Section_Order__c = 1,
        	Order__c = 1
        );
        insert HealthInspection_Profile;
    	
        PageReference credAdd = Page.CredentialAdd;
        Test.setCurrentPage(credAdd);
        
        RecordType mentorRecordType = [ SELECT Id FROM RecordType WHERE Name = 'Mentor' AND SObjectType = 'TMN_Contact__c' ];
        TMN_Contact__c tmnContact = new TMN_Contact__c(
        	RecordType = mentorRecordType
        );
        insert tmnContact;
        
        ApexPages.currentPage().getParameters().put('contactid', tmnContact.Id);

		CredentialAdd controller = new CredentialAdd();
		controller.selectedCredId = HealthInspection_Profile.Id;
		
		String nextPage = controller.CancelCredAdd().getUrl();
		
		System.assertEquals('/apex/Credential?contactid=' + tmnContact.Id, nextPage);
		
		nextPage = controller.SaveAddCred().getUrl();
		
		System.assertEquals('/apex/Credential?contactid=' + tmnContact.Id, nextPage);
		
		
		PageReference credAdd2 = Page.CredentialAdd;
		Test.setCurrentPage(credAdd2);
		
		
		RecordType householdMemberRecordType = [ SELECT Id FROM RecordType WHERE Name = 'Household Member' AND SObjectTYpe = 'TMN_Contact__c' ];
		System.debug('householdMemberRecordType: ' + householdMemberRecordType);
		List<TMN_Contact__c> tmnContactsToInsert = new List<TMN_Contact__c>();
		TMN_Contact__c coApplicant = new TMN_Contact__c(
			RecordTypeId = householdMemberRecordType.Id,
			Related_Party_Type__c = 'Co-Applicant',
			Email__c = 'test@test.com'
		);
		tmnContactsToInsert.add(coApplicant);
		TMN_Contact__c fosterParentChild = new TMN_Contact__c(
			RecordTypeId = householdMemberRecordType.Id,
			Related_Party_Type__c = 'Foster Parent\'s Child'
		);
		tmnContactsToInsert.add(fosterParentChild);
		TMN_Contact__c fosterParentRelative = new TMN_Contact__c(
			RecordTypeId = householdMemberRecordType.Id,
			Related_Party_Type__c = 'Foster Parent\'s Relative'
		);
		tmnContactsToInsert.add(fosterParentRelative);
		TMN_Contact__c nonResident = new TMN_Contact__c(
			RecordTypeId = householdMemberRecordType.Id,
			Related_Party_Type__c = 'Resident-Non Relative'
		);
		tmnContactsToInsert.add(nonResident);
		TMN_Contact__c pet = new TMN_Contact__c(
			RecordTypeId = householdMemberRecordType.Id,
			Related_Party_Type__c = 'Pet'
		);
		tmnContactsToInsert.add(pet);
		insert tmnContactsToInsert;
		System.debug('The coApplicant: ' + coApplicant);
		
		ApexPages.currentPage().getParameters().put('contactid', coApplicant.Id);
		CredentialAdd controller2 = new CredentialAdd();
		
		ApexPages.currentPage().getParameters().put('contactid', fosterParentChild.Id);
		CredentialAdd controller3 = new CredentialAdd();		

		ApexPages.currentPage().getParameters().put('contactid', fosterParentRelative.Id);
		CredentialAdd controller4 = new CredentialAdd();		

		ApexPages.currentPage().getParameters().put('contactid', nonResident.Id);
		CredentialAdd controller5 = new CredentialAdd();

		ApexPages.currentPage().getParameters().put('contactid', pet.Id);
		CredentialAdd controller6 = new CredentialAdd();
    }
}