@isTest
public with sharing class IncidentSidebarTest {
	@testSetup
	public static void setUpData() {
		TestUtils.userBuilder userBuilder = new TestUtils.UserBuilder();
		TestUtils.TmnUserBuilder tmnUserBuilder = new TestUtils.TmnUserBuilder();
		User reviewerUser = userBuilder
				.setFirstName('Reviewer')
				.setLastName('Person')
				.setUserAlias('reviewer')
				.setEmail('reviewer@tmn.com')
				.getResult();
		insert reviewerUser;

		PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'iServe_Incident_Reviewer'];
		insert new PermissionSetAssignment[] {
				new PermissionSetAssignment(
						AssigneeId = reviewerUser.Id,
						PermissionSetId = ps.Id
						)
		};

		// This is necessary since we can't mix setup and non-setup DML operations
		// in the same context. The User and PermissionSet creations above are
		// counted as setup objects, while the objects below are non-setup ones.
		System.runAs(reviewerUser) {
			TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();

			TMN_User__c reviewerTmnUser = tmnUserBuilder
					.setUserId(reviewerUser.Id)
					.setAlias(testData.alias)
					.setApprovalLevel(10)
					.getResult();
			insert reviewerTmnUser;

			Im_Incident__c incident = new Im_Incident__c(
					Name = 'I-0000000001',
					Status__c = 'Incident-Draft',
					Service_Location__c = testData.serviceLocation.Id,
					What_Happened__c = 'Random Stuff',
					When_Did_It_Happen__c = DateTime.now().addDays(-2),
					When_Was_the_Supervisor_Notified__c = DateTime.now().addDays(-1)
					);
			insert incident;
			System.assertEquals('I-0000000001', incident.Name);
			Test.setCreatedDate(incident.Id, DateTime.now());
		}
	}
	public static testmethod void simpleTests() {
		Service_Location__c serviceLocation = [SELECT Id FROM Service_Location__c];
		User reviewer = [SELECT Id FROM User WHERE Email='reviewer@tmn.com'];
		System.runAs(reviewer) {
			Im_Incident__c incident = [SELECT Id, Name FROM Im_Incident__c];
			IncidentSidebar controller = new IncidentSidebar();
			controller.incidentId = incident.Id;
			System.assertEquals(incident.Name + ' - Draft', controller.incidentName);
			System.assertEquals(true, controller.isIncidentStage);
			System.assertEquals(false, controller.isFinalized);
			System.assertEquals(true, controller.newInvestigationAllowed);
			System.assertEquals(true, controller.investigationRequirementToggleAllowed);
			System.assertEquals(true, controller.responsePlanRequirementToggleAllowed);

			System.assertEquals(false, [SELECT Id, Response_Plan_Not_Required__c FROM Im_Incident__c].Response_Plan_Not_Required__c);
			System.assertEquals(false, [SELECT Id, Investigation_Not_Required__c FROM Im_Incident__c].Investigation_Not_Required__c);

			controller.incident.Response_Plan_Not_Required__c = true;
			controller.toggleResponsePlanRequired();
			System.assertEquals(true, [SELECT Id, Response_Plan_Not_Required__c FROM Im_Incident__c].Response_Plan_Not_Required__c);

			controller.incident.Investigation_Not_Required__c = true;
			controller.toggleInvestigationRequired();
			System.assertEquals(true, [SELECT Id, Investigation_Not_Required__c FROM Im_Incident__c].Investigation_Not_Required__c);

			controller.incident.Investigation_Not_Required__c = false;
			controller.toggleInvestigationRequired();
			System.assertEquals(false, [SELECT Id, Investigation_Not_Required__c FROM Im_Incident__c].Investigation_Not_Required__c);

			controller.createInvestigation();
			Im_Investigation__c[] investigations = [SELECT Id, Status__c FROM Im_Investigation__c];
			System.assertEquals(1, investigations.size());
			System.assertEquals('Draft', investigations[0].Status__c);

			update new Im_Incident__c(
					Id = incident.Id,
					Status__c = 'Incident-Disregarded'
					);
			controller = new IncidentSidebar();
			controller.incidentId = incident.Id;
			System.assertEquals(false, controller.newInvestigationAllowed);
			System.assertEquals(false, controller.investigationRequirementToggleAllowed);
			System.assertEquals(false, controller.responsePlanRequirementToggleAllowed);
		}
	}
}
