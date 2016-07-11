@isTest
public with sharing class TmnProviderTest {
	@testSetup
	public static void setUpData() {
		TestUtils.CoreDataGenerator generator = new TestUtils.CoreDataGenerator();
		TestUtils.CoreData coreData = generator.persistData();

		insert generator.serviceAssignmentBuilder.getInstance();
	}

	public static testmethod void testDisqualifyingTriggers() {
		System.assertEquals(2, [SELECT Id FROM Service_Assignment__c].size());
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
		}
		update applications;
		System.assertEquals(6, [SELECT Id FROM Task].size());
	}

	public static testmethod void testExpiringTriggers() {
		System.assertEquals(2, [SELECT Id FROM Service_Assignment__c].size());
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
}