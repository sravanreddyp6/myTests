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
        PageReference credAdd = Page.CredentialAdd;
        Test.setCurrentPage(credAdd);
        
        RecordType mentorRecordType = [ SELECT Id FROM RecordType WHERE Name = 'Mentor' AND SObjectType = 'TMN_Contact__c' ];
        TMN_Contact__c tmnContact = new TMN_Contact__c(
        	RecordType = mentorRecordType
        );
        insert tmnContact;
        
        ApexPages.currentPage().getParameters().put('contactid', tmnContact.Id);

		CredentialAdd controller = new CredentialAdd();
		String nextPage = controller.CancelCredAdd().getUrl();
		
		System.assertEquals('/apex/Credential?contactid=' + tmnContact.Id, nextPage);
		
		nextPage = controller.SaveAddCred().getUrl();
		
		System.assertEquals('/apex/Credential?contactid=' + tmnContact.Id, nextPage);
		
		RecordType householdMemberRecordType = [ SELECT Id FROM RecordType WHERE Name = 'Household Member' AND SObjectTYpe = 'TMN_Contact__c' ];
		TMN_Contact__c coApplicant = new TMN_Contact__c(
			RecordType = householdMemberRecordType,
			Related_Party_Type__c = 'Co-Applicant',
			Email__c = 'test@test.com'
		);
		insert coApplicant;
		
		ApexPages.currentPage().getParameters().put('contactid', coApplicant.Id);
		controller = new CredentialAdd();
		
		nextPage = controller.SaveAddCred().getUrl();
		
    }
}