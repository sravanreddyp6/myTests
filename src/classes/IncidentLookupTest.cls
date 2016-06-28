@isTest
public with sharing class IncidentLookupTest {
	@testSetup
	public static void setUpData() {
		TestUtils.userBuilder userBuilder = new TestUtils.UserBuilder();
		TestUtils.TmnUserBuilder tmnUserBuilder = new TestUtils.TmnUserBuilder();
		User qualifierUser = userBuilder
			.setFirstName('Qualifier')
			.setLastName('Person')
			.setUserAlias('qualif')
			.setEmail('qualifier@tmn.com')
			.getInstance();
		User reviewerUser = userBuilder
			.setFirstName('Reviewer')
			.setLastName('Person')
			.setUserAlias('reviewer')
			.setEmail('reviewer@tmn.com')
			.getInstance();

		insert qualifierUser;
		insert reviewerUser;

		PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'iServe_Incident_Reviewer'];
		insert new PermissionSetAssignment[] {
			new PermissionSetAssignment(
				AssigneeId = qualifierUser.Id,
				PermissionSetId = ps.Id
			),
			new PermissionSetAssignment(
				AssigneeId = reviewerUser.Id,
				PermissionSetId = ps.Id
			)
		};

		// This is necessary since we can't mix setup and non-setup DML operations
		// in the same context. The User and PermissionSet creations above are
		// counted as setup objects, while the objects below are non-setup ones.
		System.runAs(qualifierUser) {
			TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();

			TMN_User__c qualifierTmnUser = tmnUserBuilder
				.setUserId(qualifierUser.Id)
				.setApprovalLevel(3)
				.setAlias(testData.alias)
				.setManagerEmail('reviewer@tmn.com')
				.getInstance();
			TMN_User__c reviewerTmnUser = tmnUserBuilder
				.setUserId(reviewerUser.Id)
				.setApprovalLevel(10)
				.getInstance();

			insert qualifierTmnUser;
			insert reviewerTmnUser;

			Eval_Type__c[] evalTypes = new Eval_Type__c[]{
				new Eval_Type__c(Name='Involved Party', Category__c='Incident Management'),
				new Eval_Type__c(Name='Involved Party Qualifying', Category__c='Incident Management')
			};
			insert evalTypes;

			TestUtils.EvalBuilder evalBuilder = new TestUtils.EvalBuilder();
			evalBuilder.setEvalType('Involved Party');
			Eval__c[] evals = new Eval__c[]{};
			evals.addAll(evalBuilder
				.setCategory('Allegations of Abuse/Neglect')
				.setSubCategory('Allegation of Neglect')
				.setInvolvedPartyType('PBS')
				.getCommonInstances()
			);
			insert evals;
		}
	}

	public static testmethod void simpleTests() {
		Service_Location__c serviceLocation = [SELECT Id FROM Service_Location__c];
		User qualifier = [SELECT Id FROM User WHERE Email='qualifier@tmn.com'];

		System.runAs(qualifier) {
			Im_Incident__c incident = new Im_Incident__c(
				Name = 'I-0000000001',
				Status__c = 'Incident-Finalized',
				Service_Location__c = serviceLocation.Id,
				What_Happened__c = 'Random Stuff',
				When_Did_It_Happen__c = DateTime.now().addDays(-2),
				When_Was_the_Supervisor_Notified__c = DateTime.now().addDays(-1)
			);
			insert incident;

			Im_InvolvedParty__c involvedPbs = new Im_InvolvedParty__c(
				Im_Incident__c = incident.Id,
				Person_Being_Served_Involved__c = [SELECT Id FROM Service_Assignment__c].Id,
				Nickname__c = 'Test PBS',
				Type__c = 'Person Being Served'
			);
			insert involvedPbs;

			Im_InvolvedParty__c involvedStaff = new Im_InvolvedParty__c(
				Im_Incident__c = incident.Id,
				Staff_Involved__c = [SELECT Id FROM Tmn_User__c WHERE Salesforce_User_Account__c = :UserInfo.getUserId()].Id,
				Nickname__c = 'Test Staff',
				Type__c = 'Staff'
			);
			insert involvedStaff;

			TestUtils.EvalValueBuilder valueBuilder = new TestUtils.EvalValueBuilder();
			valueBuilder = valueBuilder
				.setEvalType('Involved Party')
				.setWhatIdObject('Im_InvolvedParty__c')
				.setWhatId(involvedPbs.Id);
			Eval_Value__c[] values = new Eval_Value__c[]{
				valueBuilder
					.setCategory('Allegations of Abuse/Neglect')
					.setSubCategory('Allegation of Neglect')
					.setHtmlId('IsValid')
					.setValue(true)
					.getInstance()
			};
			insert values;

			System.assertEquals(1, [SELECT Id FROM Im_Incident__c].size());

			IncidentLookup controller = new IncidentLookup();
			System.assertEquals(false, controller.searchInitiated);

			System.assertEquals(2, controller.serviceLocations.size());  // one is the None option
			System.assertEquals(2, controller.eventTypes.size()); // one is the None option

			controller.finalizedIncidentsOnly = true;
			controller.pbsId = involvedPbs.Person_Being_Served_Involved__c;
			controller.staffId = involvedStaff.Staff_Involved__c;
			System.assertNotEquals('', controller.serviceLocations[1].getValue());
			System.assertNotEquals('', controller.eventTypes[1].getValue());
			controller.serviceLocation = controller.serviceLocations[1].getValue();
			controller.eventType = controller.eventTypes[1].getValue();

			System.assertEquals(involvedPbs.Person_Being_Served_Involved__c, controller.pbs.Id);
			System.assertEquals(involvedStaff.Staff_Involved__c, controller.staff.Id);

			System.debug(controller.serviceLocations);
			System.debug(controller.eventTypes);

			controller.search();
			System.assertEquals(true, controller.searchInitiated);
			System.assertEquals(1, controller.incidents.size());

			System.assertEquals(1, IncidentLookup.findPbs('{ "q": "" }').size());
			System.assertEquals(2, IncidentLookup.findStaff('{ "q": "" }').size());  // Qualifier and Reviewer
		}
	}
}