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

		Tmn_Provider__c[] providers = new Tmn_Provider__c[]{
			new Tmn_Provider__c(
				First_Name__c = 'First',
				Last_Name__c = 'Person',
				Status__c = 'Approved'
			)
		};
		insert providers;

		Tmn_Provider_Application__c[] applications = new Tmn_Provider_Application__c[]{
			new Tmn_Provider_Application__c(
				Provider__c = providers[0].Id,
				Effective_Date__c = Date.today().addMonths(-1),
				Expiration_Date__c = Date.today().addMonths(1),
				Status__c = 'Approved'
			)
		};
		insert applications;
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

		System.assertEquals(null, controller.save()); // Validation error here
		controller.agreement.Tmn_Provider__c = [SELECT Id FROM Tmn_Provider__c].Id;
		controller.agreement.Start_Date__c = Date.today();
		controller.agreement.End_Date__c = Date.today().addDays(-1);

		// Validation errors since start date > end date
		System.assertEquals(null, controller.save());

		controller.agreement.End_Date__c = Date.today().addYears(2);

		// Validation errors since since end date > start date + 13 months
		System.assertEquals(null, controller.save());

		controller.agreement.Start_Date__c = Date.today().addMonths(-2);
		controller.agreement.End_Date__c = Date.today().addDays(15);

		// Validation errors since start date not within application range
		System.assertEquals(null, controller.save());

		controller.agreement.Start_Date__c = Date.today();
		controller.save();
	}
}