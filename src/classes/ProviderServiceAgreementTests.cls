@isTest
public with sharing class ProviderServiceAgreementTests {
	@testSetup
	public static void setUpData() {
		TestUtils.CoreDataGenerator generator = new TestUtils.CoreDataGenerator();
		generator.aliasBuilder
			.setState('OR')
			.setName('038025');  // Mid Valley
		generator.serviceLocationBuilder.setState('OR');
		generator.serviceLocationBuilder
			.setServiceType('CM - Case Management')
			.setProgramId('111111000')
			.setLocationNickname('Brokerage 1');
		TestUtils.CoreData coreData = generator.persistData();
	}

	public static testmethod void simpleTests() {
		PageReference pageRef = Page.ProviderServiceAgreement;
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('saId', [SELECT Id FROM Service_Assignment__c LIMIT 1].Id);
		Service_Assignment_Provider_JO__c agreement = new Service_Assignment_Provider_JO__c();
		ProviderServiceAgreement controller = new ProviderServiceAgreement(new ApexPages.StandardController(agreement));
		System.assertEquals(false, controller.isViewMode);
		System.assertEquals(true, controller.isNewMode);
		System.assertEquals(true, controller.isEditMode);
		System.assertEquals(false, controller.getIsLocked());
		System.assertEquals(true, controller.isMidValley);
		System.assertEquals(false, controller.isMetro);
		System.assertEquals(true, controller.canFinalize);
		System.assertEquals(0, controller.getServiceCodes().size());
		System.assertEquals(0, controller.getCheckedServiceCodes().size());
		System.assertEquals(null, controller.getAssociatedIsp());
		System.assertEquals(false, controller.getHasInactiveDraftIsp());
		System.assertEquals(0, controller.getCommonLawEmployerOptions().size());
		System.assertEquals('N/a', controller.getCommonLawEmployer());
		System.assertEquals(0, controller.getEmergencyContactOptions().size());
		System.assertEquals('N/a', controller.getEmergencyContact());
		System.assertEquals(0, controller.getRisks().size());
		System.assertEquals('New Provider Service Agreement Association', controller.getTitle());
	}
}