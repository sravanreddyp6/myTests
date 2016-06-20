@isTest
public with sharing class IncidentManagementTest {
	@testSetup
	public static void setUpData() {
		TestUtils.userBuilder userBuilder = new TestUtils.UserBuilder();
		TestUtils.TmnUserBuilder tmnUserBuilder = new TestUtils.TmnUserBuilder();
		User qualifierUser = userBuilder
			.setFirstName('Qualifier')
			.setLastName('Person')
			.setUserAlias('qualif')
			.setEmail('qualifier@tmn.com')
			.getResult();
		User reviewerUser = userBuilder
			.setFirstName('Reviewer')
			.setLastName('Person')
			.setUserAlias('reviewer')
			.setEmail('reviewer@tmn.com')
			.getResult();

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

		User currentUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
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
				.getResult();
			TMN_User__c reviewerTmnUser = tmnUserBuilder
				.setUserId(reviewerUser.Id)
				.setApprovalLevel(10)
				.getResult();

			insert qualifierTmnUser;
			insert reviewerTmnUser;

			Eval_Type__c[] evalTypes = new Eval_Type__c[]{
				new Eval_Type__c(Name='Involved Party', Category__c='Incident Management'),
				new Eval_Type__c(Name='Involved Party Qualifying', Category__c='Incident Management')
			};
			insert evalTypes;
			TestUtils.EvalBuilder evalBuilder = new TestUtils.EvalBuilder();
			evalBuilder.setEvalTypeId(evalTypes[0].Id);
			Eval__c[] evals = new Eval__c[]{
				evalBuilder
					.setCategory('Allegations of Abuse/Neglect')
					.setSubCategory('Allegation of Neglect')
					.setHtmlId('IsValid')
					.setFieldType('Hidden')
					.setFieldSubType('Boolean')
					.setInvolvedPartyType('PBS')
					.getResult(),
				evalBuilder.setSubCategory('Allegation of Abuse - Physical').getResult(),
				evalBuilder.setSubCategory('Allegation of Abuse - Sexual').getResult()
			};
			insert evals;
		}
	}

	public static testmethod void testCreatingQualifier() {
		Service_Location__c serviceLocation = [SELECT Id FROM Service_Location__c];
		User qualifier = [SELECT Id FROM User WHERE Email='qualifier@tmn.com'];

		System.runAs(qualifier) {
			Im_Incident__c incident = new Im_Incident__c();
			IncidentManagement controller = new IncidentManagement(
					new ApexPages.standardController(incident)
			);
			System.assertEquals(false, controller.getIsLocked());
			System.assertEquals(false, controller.isViewMode);
			System.assertEquals(true, controller.isEditMode);
			System.assertEquals(true, controller.isQualifyingStage);
			System.assertEquals(false, controller.isIncidentStage);
			System.assertEquals('Create Qualifier', controller.name);
			System.assertEquals(serviceLocation.Id, controller.incident.Service_Location__c);
			List<MyRemoteMethods.SelOption> staffOptions = IncidentManagement.getStaffForProgram(
				String.format(
					'\'{\' "programLocation": "{0}", "q": "" \'}\'',
					new String[] { serviceLocation.Id }
				)
			);
			System.assertEquals(2, staffOptions.size(), 'Staff Notified should contain the qualifier and reviewer');
			controller.incident.Notified_Staff__c = staffOptions[0].Id + ',' + staffOptions[1].Id;
			System.assert(controller.notifiedStaffNames.indexOf('Qualifier') != -1);
			System.assert(controller.notifiedStaffNames.indexOf('Reviewer') != -1);
			System.assertEquals(2, controller.serviceLocations.size(), 'Service Locations should contain a None option and the actual Location');
			controller.incident.Agencies_Notified__c = 'Funding Source';
			System.assertNotEquals('', controller.agenciesNotifiedOptions);

			controller.incident.Service_Location__c = null;
			controller.save();  // validation errors here
			System.assertNotEquals(0, ApexPages.getMessages().size());

			controller.incident.When_Did_It_Happen__c = DateTime.now().addDays(2);
			controller.incident.When_Was_the_Supervisor_Notified__c = DateTime.now().addDays(1);
			controller.save();  // validation errors here
			System.assertNotEquals(0, ApexPages.getMessages().size());

			controller.incident.Service_Location__c = serviceLocation.Id;
			controller.incident.What_Happened__c = 'Random Stuff';
			controller.incident.When_Did_It_Happen__c = DateTime.now().addDays(-2);
			controller.incident.When_Was_the_Supervisor_Notified__c = DateTime.now().addDays(-1);
			controller.save();  // should be good to go here
			System.assertNotEquals(null, controller.incident.Id);
			System.assertEquals('Event-Qualifying', controller.incident.Status__c);
		}
	}
	public static testMethod void testCloseEvent() {
		Service_Location__c serviceLocation = [SELECT Id FROM Service_Location__c];
		User qualifier = [SELECT Id FROM User WHERE Email='qualifier@tmn.com'];

		System.runAs(qualifier) {
			Im_Incident__c incident = new Im_Incident__c(
				Status__c = 'Event-Qualifying',
				Service_Location__c = serviceLocation.Id,
				What_Happened__c = 'Random Stuff',
				When_Did_It_Happen__c = DateTime.now().addDays(-2),
				When_Was_the_Supervisor_Notified__c = DateTime.now().addDays(-1)
			);
			insert incident;
			IncidentManagement controller = new IncidentManagement(
				new ApexPages.standardController(incident)
			);
			controller.close();
			System.assertEquals('Event-Closed', controller.incident.Status__c);
			System.assertEquals(true, controller.getIsLocked());
		}
	}

	public static testMethod void testQualifyingAsIncident() {
		Service_Location__c serviceLocation = [SELECT Id FROM Service_Location__c];
		User qualifier = [SELECT Id FROM User WHERE Email='qualifier@tmn.com'];

		System.runAs(qualifier) {
			Im_Incident__c incident = new Im_Incident__c(
				Name = 'E-0000000000Q',
				Status__c = 'Event-Qualifying',
				Service_Location__c = serviceLocation.Id,
				What_Happened__c = 'Random Stuff',
				When_Did_It_Happen__c = DateTime.now().addDays(-2),
				When_Was_the_Supervisor_Notified__c = DateTime.now().addDays(-1)
			);
			insert incident;
			IncidentManagement controller = new IncidentManagement(
				new ApexPages.standardController(incident)
			);
			System.assertEquals(incident.Name + ' - Qualifying', controller.name);

			List<MyRemoteMethods.SelOption> pbsOptions = IncidentManagement.getPBSForProgram(
				String.format(
					'\'{\' "programLocation": "{0}", "q": "" \'}\'',
					new String[] { serviceLocation.Id }
				)
			);
			System.assertEquals(1, pbsOptions.size());

			Map<String, object> validateResult = IncidentManagement.validateEvent(controller.incident.Id);
			System.assertEquals(false, (Boolean) validateResult.get('goodToSubmit'), 'The event validation should fail since there is no event type added yet');
			Im_InvolvedParty__c involvedPbs = new Im_InvolvedParty__c(
					Im_Incident__c = controller.incident.Id,
					Person_Being_Served_Involved__c = [SELECT Id FROM Service_Assignment__c].Id,
					Nickname__c = 'Test PBS',
					Type__c = 'Person Being Served'
			);
			insert involvedPbs;
			String eventTypes = IncidentManagement.getInvolvedPartyEventTypes('{ "involvedParty": "' + involvedPbs.Id + '", "involvedPartyType": "Person Being Served" }');
			System.assert(eventTypes.indexOf('Allegation of Neglect') != -1);

			validateResult = IncidentManagement.validateEvent(controller.incident.Id);
			System.assertEquals(false, (Boolean) validateResult.get('goodToSubmit'), 'The event validation should fail since there is no event added yet');

			TestUtils.EvalValueBuilder valueBuilder = new TestUtils.EvalValueBuilder();
			valueBuilder = valueBuilder
				.setEvalType('Involved Party')
				.setWhatIdObject('Im_InvolvedParty__c')
				.setWhatId(involvedPbs.Id);
			Eval_Value__c[] values = new Eval_Value__c[]{
				valueBuilder.setCategory('Allegations of Abuse/Neglect').setSubCategory('Allegation of Neglect').setHtmlId('IsValid').setValue(true).getResult()
			};
			insert values;
			validateResult = IncidentManagement.validateEvent(controller.incident.Id);
			System.assertEquals(true, (Boolean) validateResult.get('goodToSubmit'), 'The event validation should pass now');

			List<MyRemoteMethods.Im_PartyData> involvedParties = IncidentManagement.getInvolvedParties(controller.incident.Id);
			System.assertEquals(1, involvedParties.size());

			List<String> partyDetails = IncidentManagement.getEventDetails(involvedPbs.Id, false);
			System.assertNotEquals(0, partyDetails.size());

			controller.qualifyEvent();
			controller.reloadCalculatedLevel();
			System.assertEquals('3', controller.incident.Calculated_Level__c);
			System.assertNotEquals('', controller.incident.Calculated_Level_Explanation__c);
			System.assertEquals('Incident-Draft', controller.incident.Status__c);

			// Update the event here
			Eval__c eval = [
				SELECT Id
				  FROM Eval__c
				 WHERE Category__c = 'Allegations of Abuse/Neglect'
				   AND Sub_Category__c = 'Allegation of Neglect'
				   AND HtmlId__c = 'IsValid'
				];
			IncidentManagement.saveFields(involvedPbs.Id, '[{"name": "'+ eval.Id +'_esi", "value": false}]');
			Eval_Value__c value = [
				SELECT Id, Boolean__c
				  FROM Eval_Value__c
				 WHERE Eval__c = :eval.Id
				   AND What_Id__c = :involvedPbs.Id
			];
			System.assertEquals(true, value.Boolean__c);
		}
	}

	public static testMethod void testReadyForReviewIncident() {
		Service_Location__c serviceLocation = [SELECT Id FROM Service_Location__c];
		User qualifier = [SELECT Id FROM User WHERE Email='qualifier@tmn.com'];
		Tmn_User__c reviewer = [SELECT Id FROM Tmn_User__c WHERE Email__c='reviewer@tmn.com'];

		System.runAs(qualifier) {
			Im_Incident__c incident = new Im_Incident__c(
				Name = 'I-0000000001',
				Status__c = 'Incident-Draft',
				Service_Location__c = serviceLocation.Id,
				What_Happened__c = 'Random Stuff',
				When_Did_It_Happen__c = DateTime.now().addDays(-2),
				When_Was_the_Supervisor_Notified__c = DateTime.now().addDays(-1)
			);
			insert incident;
			IncidentManagement controller = new IncidentManagement(
				new ApexPages.standardController(incident)
			);
			List<MyRemoteMethods.SelOption> reviewers = IncidentManagement.getIncidentReviewers(
				String.format(
					'\'{\' "programLocation": "{0}", "q": "" \'}\'',
					new String[] { serviceLocation.Id }
				)
			);
			System.assertEquals(1, reviewers.size());
			System.assertEquals(reviewer.Id, reviewers[0].Id);
			controller.readyForReview();  // should fail validation since final level and reviewer is not filled in yet

			ApexPages.Message[] messages = ApexPages.getMessages();
			System.assertEquals(2, messages.size());

			controller.incident.Incident_Reviewer__c = reviewer.Id;
			controller.incident.Final_Level__c = '4';
			controller.readyForReview();
			System.assertNotEquals(0, ApexPages.getMessages().size());  // Level Reason required

			controller.incident.Final_Level_Reason__c = 'Reason';
			controller.readyForReview();
			System.assertEquals('Incident-Ready for Review', controller.incident.Status__c);
		}
	}

	public static testMethod void testFinalizeIncident() {
		Service_Location__c serviceLocation = [SELECT Id FROM Service_Location__c];
		User qualifier = [SELECT Id FROM User WHERE Email='qualifier@tmn.com'];
		User reviewer = [SELECT Id FROM User WHERE Email='reviewer@tmn.com'];

		System.runAs(qualifier) {
			Im_Incident__c incident = new Im_Incident__c(
				Name = 'I-0000000001',
				Status__c = 'Incident-Ready for Review',
				Service_Location__c = serviceLocation.Id,
				What_Happened__c = 'Random Stuff',
				When_Did_It_Happen__c = DateTime.now().addDays(-2),
				When_Was_the_Supervisor_Notified__c = DateTime.now().addDays(-1)
			);
			insert incident;
		}
		System.runAs(reviewer) {
			Im_Incident__c incident = [ SELECT Id FROM Im_Incident__c ];
			IncidentManagement controller = new IncidentManagement();
			System.assertEquals(false, controller.isQualifyingStage);
			System.assertEquals(false, controller.isIncidentStage);
			controller.handle(incident.Id, UserInfo.getUserId());
			incident = [ SELECT Id, Status__c FROM Im_Incident__c WHERE Id=:incident.Id ];
			System.assertEquals('Incident-Finalized', incident.Status__c);

			Test.setCurrentPage(Page.IncidentManagement);
			System.currentPageReference().getParameters().put('mode', 'view');
			controller = new IncidentManagement(
				new ApexPages.standardController(incident)
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
		}
	}
}
