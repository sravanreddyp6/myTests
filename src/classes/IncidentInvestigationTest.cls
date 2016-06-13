@isTest
public with sharing class IncidentInvestigationTest {
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
			Test.setCreatedDate(incident.Id, DateTime.now());

			IncidentInvestigationModel.createInvestigation(incident.Id);
		}
	}
	public static testmethod void testDraftInvestigation() {
		Service_Location__c serviceLocation = [SELECT Id FROM Service_Location__c];
		User reviewer = [SELECT Id FROM User WHERE Email='reviewer@tmn.com'];
		System.runAs(reviewer) {
			Im_Investigation__c investigation = [
				SELECT Id, Status__c, Investigation_Start_Date__c, Im_Incident__r.CreatedDate
				  FROM Im_Investigation__c
			];
			System.assertEquals(Date.today(), investigation.Im_Incident__r.CreatedDate.date());
			IncidentInvestigation controller = new IncidentInvestigation(
					new ApexPages.StandardController(investigation)
					);
			System.assertEquals(true, controller.isViewMode);
			System.assertEquals(false, controller.isEditMode);
			System.assertEquals(false, controller.isFinalized);
			System.assertEquals(false, controller.isLocked);

			controller.save();  // validation error since no start date is specified
			System.assertNotEquals(0, ApexPages.getMessages().size());

			controller.investigation.Investigation_Start_Date__c = DateTime.now().addDays(-1);
			controller.save();  // validation error since start date is later than Incident date

			System.assertEquals(null, [SELECT Id, Investigation_Start_Date__c FROM Im_Investigation__c].Investigation_Start_Date__c);

			controller.investigation.Investigation_Start_Date__c = DateTime.now().addDays(1);
			controller.save();
			System.assertNotEquals(null, [SELECT Id, Investigation_Start_Date__c FROM Im_Investigation__c].Investigation_Start_Date__c);

			System.assertEquals(0, controller.incidentAssociations.size());

			// Test auto association here
			Im_Incident__c finalizedIncident = new Im_Incident__c(
					Name = 'I-0000000001',
					Status__c = 'Incident-Draft',
					Service_Location__c = serviceLocation.Id,
					What_Happened__c = 'Random Stuff',
					When_Did_It_Happen__c = DateTime.now().addDays(-2),
					When_Was_the_Supervisor_Notified__c = DateTime.now().addDays(-1),
					Date_Documented__c = DateTime.now(),
					Final_Level__c = '3'
					);
			insert finalizedIncident;

			controller.lookedUpIncidentId = finalizedIncident.Id;
			controller.createNewAutoAssociation();
			System.assertNotEquals(null, controller.currentAutoAssociation.Date_of_Association__c);
			System.assertEquals('Reviewer Person', controller.currentAutoAssociation.Association_Made_By__c);

			controller.currentAutoAssociation.Date_of_Association__c = null;
			controller.currentAutoAssociation.Association_Made_By__c = null;
			controller.saveAutoAssociation();  // should fail validation here since nothing is filled in

			System.assertEquals(0, [SELECT Id FROM Evaluation_Response__c WHERE RecordType.Name = 'Auto Incident Investigation JO'].size());

			controller.currentAutoAssociation.Source__c = 'IRS';
			controller.currentAutoAssociation.Comment__c = 'Comment';
			controller.currentAutoAssociation.Date_of_Association__c = DateTime.now();
			controller.currentAutoAssociation.Association_Made_By__c = 'Reviewer Person';
			controller.saveAutoAssociation();

			System.assertEquals(1, [SELECT Id FROM Evaluation_Response__c WHERE RecordType.Name = 'Auto Incident Investigation JO'].size());

			// Test manual association
			controller.createNewManualAssociation();
			System.assertNotEquals(null, controller.currentManualAssociation.Date_of_Association__c);
			System.assertEquals('Reviewer Person', controller.currentManualAssociation.Association_Made_By__c);

			controller.currentAutoAssociation.Date_of_Association__c = null;
			controller.currentAutoAssociation.Association_Made_By__c = null;
			controller.saveManualAssociation(); // should fail validation here since nothing is filled in
			System.assertEquals(0, [SELECT Id FROM Evaluation_Response__c WHERE RecordType.Name = 'Manual Incident Investigation JO'].size());

			controller.currentManualAssociation.Incident_Number__c = 'Incident Number';
			controller.currentManualAssociation.Date_of_Incident__c = DateTime.now();
			controller.currentManualAssociation.Final_Level__c = 3;
			controller.currentManualAssociation.Program_Association__c = 'Test Program';
			controller.currentManualAssociation.Source__c = 'IRS';
			controller.currentManualAssociation.Comment__c = 'Comment';
			controller.currentManualAssociation.Date_of_Association__c = DateTime.now();
			controller.currentManualAssociation.Association_Made_By__c = 'Reviewer Person';

			controller.saveManualAssociation();
			System.assertEquals(1, [SELECT Id FROM Evaluation_Response__c WHERE RecordType.Name = 'Manual Incident Investigation JO'].size());

			// Test finding internal investigating parties here
			List<MyRemoteMethods.SelOption> parties = IncidentInvestigation.findInternalInvestigatingParties('{ "q": "", "investigationId": "' + controller.investigation.Id + '" }');
			System.assertEquals(1, parties.size());  // should just find yourself

			controller.investigation.Internal_Investigating_Parties__c = parties[0].Id;
			controller.save();

			System.assertEquals('Reviewer Person', controller.internalInvestigatingPartyNames);

			// Test finalizing
			controller.finalize();  // should fail validation here since there's a bunch of stuff that need filling in
			System.assertEquals('Draft', controller.investigation.Status__c);

			controller.investigation.Investigation_End_Date__c = DateTime.now();
			controller.investigation.Factual_Findings__c = 'Test Internal Findings';
			controller.investigation.Conclusion_of_Fact__c = 'Test Internal Conclusion';
			controller.investigation.Summary_on_Conclusion__c = 'Test Internal Summary';
			controller.investigation.External_Factual_Findings__c = 'Test External Findings';
			controller.investigation.External_Conclusion_of_Fact__c = 'Test External Conclusion';
			controller.investigation.External_Summary_on_Conclusion__c = 'Test External Summary';

			controller.finalize();  // should still fail validation here since end date earlier than start date
			System.assertEquals('Draft', controller.investigation.Status__c);

			controller.investigation.Investigation_End_Date__c = DateTime.now().addDays(-5);
			controller.finalize();  // should still fail validation here since end date earlier than incident date
			System.assertEquals('Draft', controller.investigation.Status__c);

			controller.investigation.Investigation_End_Date__c = DateTime.now().addDays(5);
			controller.finalize();
			System.assertEquals('Finalized', controller.investigation.Status__c);

			Test.setCurrentPage(Page.IncidentInvestigation);
			System.currentPageReference().getParameters().put('mode', 'view');
			controller = new IncidentInvestigation(
					new ApexPages.standardController(investigation)
					);
			controller.showAddLogEntry();
			controller.currEntry.evalResp.Narrative_Note__c = 'n'.repeat(200);
			controller.saveLogEntry();

			System.assertEquals(1, controller.getAddendumEntries().size());
			System.assertEquals('n'.repeat(99) + '...', controller.getAddendumEntries()[0].briefDesc);

			controller.showEditLogEntry();
			controller.saveLogEntry();
			controller.currEntryId = controller.currEntry.evalResp.Id;
			controller.showEditLogEntry();
			controller.disregardLogEntry();

			System.assertEquals(2, controller.getAddendumEntries().size());

			// Test disregarding
			controller.disregard();
			System.assertEquals('Disregarded', [SELECT Id, Status__c FROM Im_Investigation__c].Status__c);
		}
	}
}