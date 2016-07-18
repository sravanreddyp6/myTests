@isTest
public with sharing class TmnProviderTest {
	@testSetup
	public static void setUpData() {
		TestUtils.CoreDataGenerator generator = new TestUtils.CoreDataGenerator();
		generator.aliasBuilder.setState('OR');
		generator.serviceLocationBuilder.setState('OR');
		generator.serviceLocationBuilder
			.setServiceType('CM - Case Management')
			.setProgramId('111111000')
			.setLocationNickname('Brokerage 1');
		TestUtils.CoreData coreData = generator.persistData();

		insert generator.serviceAssignmentBuilder.getInstance();
	}

	public static testmethod void testDisqualifyingTriggers() {
		Tmn_Provider__c[] providers = new Tmn_Provider__c[]{
			new Tmn_Provider__c(
				First_Name__c = 'First',
				Last_Name__c = 'Person',
				Status__c = 'Approved'
			),
			new Tmn_Provider__c(
				First_Name__c = 'Second',
				Last_Name__c = 'Human',
				Status__c = 'Approved'
			)
		};
		insert providers;

		Tmn_Provider_Application__c[] applications = new Tmn_Provider_Application__c[]{
			new Tmn_Provider_Application__c(
				Provider__c = providers[0].Id,
				Status__c = 'Approved'
			),
			new Tmn_Provider_Application__c(
				Provider__c = providers[1].Id,
				Status__c = 'Approved'
			)
		};
		insert applications;

		TestUtils.UserBuilder userBuilder = new TestUtils.UserBuilder();
		User[] users = new User[]{
			userBuilder.setFirstName('No1').setLastName('User').setUserAlias('no1u').setEmail('no1@test.com').getInstance(),
			userBuilder.setFirstName('No2').setLastName('User').setUserAlias('no2u').setEmail('no2@test.com').getInstance()
		};
		insert users;

		Alias__c alias = [SELECT Id, Name FROM Alias__c];
		TestUtils.TmnUserBuilder tmnUserBuilder = new TestUtils.TmnUserBuilder();
		Tmn_User__c[] personalAgents = new Tmn_User__c[]{
			tmnUserBuilder.setUserId(users[0].Id).setAlias(alias).getInstance(),
			tmnUserBuilder.setUserId(users[1].Id).setAlias(alias).getInstance()
		};
		insert personalAgents;

		Service_Assignment__c[] serviceAssignments = [
			SELECT Id FROM Service_Assignment__c
		];

		Service_Assignment_Provider_JO__c[] associations = new Service_Assignment_Provider_JO__c[]{
			new Service_Assignment_Provider_JO__c(
				Service_Assignment__c = serviceAssignments[0].Id,
				Tmn_Provider__c = providers[0].Id,
				Status__c = 'Active'
			),
			new Service_Assignment_Provider_JO__c(
				Service_Assignment__c = serviceAssignments[0].Id,
				Tmn_Provider__c = providers[1].Id,
				Status__c = 'Active'
			),
			new Service_Assignment_Provider_JO__c(
				Service_Assignment__c = serviceAssignments[1].Id,
				Tmn_Provider__c = providers[0].Id,
				Status__c = 'Active'
			),
			new Service_Assignment_Provider_JO__c(
				Service_Assignment__c = serviceAssignments[1].Id,
				Tmn_Provider__c = providers[1].Id,
				Status__c = 'Active'
			)
		};
		insert associations;

		Service_Assignment_Personal_Agent__c[] paAssociations = new Service_Assignment_Personal_Agent__c[] {
			new Service_Assignment_Personal_Agent__c(
				Service_Assignment__c = serviceAssignments[0].Id,
				Personal_Agent__c = personalAgents[0].Id,
				Status__c = 'Active'
			),
			new Service_Assignment_Personal_Agent__c(
				Service_Assignment__c = serviceAssignments[0].Id,
				Personal_Agent__c = personalAgents[1].Id,
				Status__c = 'Active'
			),
			new Service_Assignment_Personal_Agent__c(
				Service_Assignment__c = serviceAssignments[1].Id,
				Personal_Agent__c = personalAgents[0].Id,
				Status__c = 'Active'
			)
		};
		insert paAssociations;
		for (Tmn_Provider_Application__c application: applications) {
			application.Status__c = 'Disqualified';
			application.Disqualified__c = true;
		}
		update applications;
		System.assertEquals(6, [SELECT Id FROM Task].size());
	}

	public static testmethod void testExpiringTriggers() {
		Tmn_Provider__c[] providers = new Tmn_Provider__c[]{
			new Tmn_Provider__c(
				First_Name__c = 'First',
				Last_Name__c = 'Person',
				Status__c = 'Approved'
			),
			new Tmn_Provider__c(
				First_Name__c = 'Second',
				Last_Name__c = 'Human',
				Status__c = 'Approved'
			)
		};
		insert providers;

		Tmn_Provider_Application__c[] applications = new Tmn_Provider_Application__c[]{
			new Tmn_Provider_Application__c(
				Provider__c = providers[0].Id,
				Status__c = 'Approved'
			),
			new Tmn_Provider_Application__c(
				Provider__c = providers[1].Id,
				Status__c = 'Approved'
			)
		};
		insert applications;

		TestUtils.UserBuilder userBuilder = new TestUtils.UserBuilder();
		User[] users = new User[]{
			userBuilder.setFirstName('No1').setLastName('User').setUserAlias('no1u').setEmail('no1@test.com').getInstance(),
			userBuilder.setFirstName('No2').setLastName('User').setUserAlias('no2u').setEmail('no2@test.com').getInstance()
		};
		insert users;

		Alias__c alias = [SELECT Id, Name FROM Alias__c];
		TestUtils.TmnUserBuilder tmnUserBuilder = new TestUtils.TmnUserBuilder();
		Tmn_User__c[] personalAgents = new Tmn_User__c[]{
			tmnUserBuilder.setUserId(users[0].Id).setAlias(alias).getInstance(),
			tmnUserBuilder.setUserId(users[1].Id).setAlias(alias).getInstance()
		};
		insert personalAgents;

		Service_Assignment__c[] serviceAssignments = [
			SELECT Id FROM Service_Assignment__c
		];

		Service_Assignment_Provider_JO__c[] associations = new Service_Assignment_Provider_JO__c[]{
			new Service_Assignment_Provider_JO__c(
				Service_Assignment__c = serviceAssignments[0].Id,
				Tmn_Provider__c = providers[0].Id,
				Status__c = 'Active'
			),
			new Service_Assignment_Provider_JO__c(
				Service_Assignment__c = serviceAssignments[0].Id,
				Tmn_Provider__c = providers[1].Id,
				Status__c = 'Active'
			),
			new Service_Assignment_Provider_JO__c(
				Service_Assignment__c = serviceAssignments[1].Id,
				Tmn_Provider__c = providers[0].Id,
				Status__c = 'Active'
			),
			new Service_Assignment_Provider_JO__c(
				Service_Assignment__c = serviceAssignments[1].Id,
				Tmn_Provider__c = providers[1].Id,
				Status__c = 'Active'
			)
		};
		insert associations;

		Service_Assignment_Personal_Agent__c[] paAssociations = new Service_Assignment_Personal_Agent__c[] {
			new Service_Assignment_Personal_Agent__c(
				Service_Assignment__c = serviceAssignments[0].Id,
				Personal_Agent__c = personalAgents[0].Id,
				Status__c = 'Active'
			),
			new Service_Assignment_Personal_Agent__c(
				Service_Assignment__c = serviceAssignments[0].Id,
				Personal_Agent__c = personalAgents[1].Id,
				Status__c = 'Active'
			),
			new Service_Assignment_Personal_Agent__c(
				Service_Assignment__c = serviceAssignments[1].Id,
				Personal_Agent__c = personalAgents[0].Id,
				Status__c = 'Active'
			)
		};
		insert paAssociations;
		for (Tmn_Provider_Application__c application: applications) {
			application.Status__c = 'Expired';
		}
		update applications;
		System.assertEquals(6, [SELECT Id FROM Task].size());
	}

	public static testmethod void testExpiringBatchJob() {
		Tmn_Provider__c[] providers = new Tmn_Provider__c[]{
			new Tmn_Provider__c(
				First_Name__c = 'First',
				Last_Name__c = 'Person',
				Status__c = 'Approved'
			),
			new Tmn_Provider__c(
				First_Name__c = 'Second',
				Last_Name__c = 'Human',
				Status__c = 'Approved'
			)
		};
		insert providers;

		Tmn_Provider_Application__c[] applications = new Tmn_Provider_Application__c[]{
			new Tmn_Provider_Application__c(
				Provider__c = providers[0].Id,
				Status__c = 'Approved',
				Expiration_Date__c = Date.Today().addDays(-1)
			),
			new Tmn_Provider_Application__c(
				Provider__c = providers[1].Id,
				Status__c = 'Approved',
				Expiration_Date__c = Date.Today().addDays(2)
			)
		};
		insert applications;

		Test.startTest();
		Database.executeBatch(new TmnProviderExpirationBatch(), 100);
		Test.stopTest();

		Tmn_Provider_Application__c application1 = [
			SELECT Id, Status__c, Provider__r.Status__c FROM Tmn_Provider_Application__c WHERE Id=:applications[0].Id
		];
		System.assertEquals('Expired', application1.Provider__r.Status__c);
		System.assertEquals('Expired', application1.Status__c);

		Tmn_Provider_Application__c application2 = [
			SELECT Id, Status__c, Provider__r.Status__c FROM Tmn_Provider_Application__c WHERE Id=:applications[1].Id
		];
		System.assertEquals('Approved', application2.Provider__r.Status__c);
		System.assertEquals('Approved', application2.Status__c);
	}

	public static testmethod void simpleTests() {
		Tmn_Provider__c provider = new Tmn_Provider__c();
		TmnProvider controller = new TmnProvider(new ApexPages.StandardController(provider));
		System.assertEquals(false, controller.isViewMode);
		System.assertEquals(true, controller.isNewMode);
		System.assertEquals(true, controller.isEditMode);
		System.assertEquals(false, controller.getIsLocked());
		System.assertEquals('New Applicant', controller.getTitle());
		System.assertEquals(1, controller.getBrokerageOptions().size());

		controller.provider.Brokerage__c = controller.getBrokerageOptions()[0].getValue();
		System.assertEquals('111111000 - Brokerage 1', controller.getBrokerage());
		controller.provider.First_Name__c = 'First';
		controller.provider.Last_Name__c = 'Last';
		controller.provider.Gender__c = 'Male';

		System.assertNotEquals(null, controller.save());

		Tmn_Provider_Application__c[] applications = new Tmn_Provider_Application__c[]{
			new Tmn_Provider_Application__c(
				Status__c = 'Approved',
				Provider__c = controller.provider.Id
			),
			new Tmn_Provider_Application__c(
				Status__c = 'Pending Approval',
				Provider__c = controller.provider.Id
			)
		};
		insert applications;

		Service_Assignment__c serviceAssignment = [SELECT Id FROM Service_Assignment__c LIMIT 1];
		Service_Assignment_Provider_JO__c[] associations = new Service_Assignment_Provider_JO__c[]{
			new Service_Assignment_Provider_JO__c(
				Tmn_Provider__c = controller.provider.Id,
				Service_Assignment__c = serviceAssignment.Id,
				Status__c = 'Active'
			)
		};
		insert associations;

		provider = [SELECT Id, Name, First_Name__c, Last_Name__c, Gender__c FROM Tmn_Provider__c WHERE Id=:controller.provider.Id];
		controller = new TmnProvider(new ApexPages.StandardController(provider));
		System.assertEquals(true, controller.isViewMode);
		System.assertNotEquals(null, controller.currentDisqualifiableApplication);
		System.assertNotEquals(null, controller.currentPendingApplicationId);
		System.assertEquals('First Last', controller.getTitle());

		System.assertEquals(null, controller.disqualify());  // trigger the validation error

		controller.currentDisqualifiableApplication.Disqualification_Date__c = Date.today();
		controller.currentDisqualifiableApplication.Reason_for_Disqualification__c = 'Test Reason';
		controller.disqualify();

		System.assertEquals(true, [SELECT Id, Disqualified__c FROM Tmn_Provider_Application__c WHERE Id=:applications[0].Id].Disqualified__c);
		System.assertEquals(1, controller.getAssociations().size());
		controller.getAssociations();  // just to trigger the cache

		Tmn_Provider__c oldProvider = controller.provider;
		provider = new Tmn_Provider__c();
		controller = new TmnProvider(new ApexPages.StandardController(provider));
		// Trigger the dedupe here
		controller.provider.First_Name__c = 'First';
		controller.provider.Last_Name__c = 'Last';
		controller.provider.Gender__c = 'Male';

		System.assertEquals(null, controller.save());
		System.assertEquals(oldProvider.Id, controller.similarProviders[0].Id);
		controller.saveWithoutDedupe();
		System.assertNotEquals(null, controller.provider.Id);

		provider = new Tmn_Provider__c();
		controller = new TmnProvider(new ApexPages.StandardController(provider));
		System.assertEquals('N/a', controller.getBrokerage());
		controller.getBrokerage(); // Just to trigger the cache
		// Trigger validation here
		System.assertEquals(null, controller.save());
	}
}