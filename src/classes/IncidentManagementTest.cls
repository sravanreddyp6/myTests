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
			evals.addAll(evalBuilder
				.setSubCategory('Allegation of Abuse - Physical')
				.getCommonInstances()
			);
			evals.addAll(evalBuilder
				.setSubCategory('Allegation of Abuse - Sexual')
				.getCommonInstances()
			);
			evals.addAll(evalBuilder
				.setCategory('Intervention')
				.setSubCategory('Seclusion')
				.getCommonInstances()
			);
			evals.addAll(evalBuilder
				.setCategory('All Others')
				.setSubCategory('Death')
				.getCommonInstances()
			);
			evals.addAll(evalBuilder
				.setSubCategory('Medical Attention')
				.getCommonInstances()
			);
			evals.addAll(evalBuilder
				.setCategory('Behavioral')
				.setSubCategory('Law Enforcement Involvement')
				.getCommonInstances()
			);
			evals.addAll(evalBuilder
				.setSubCategory('Sexual Aggression/Assault')
				.getCommonInstances()
			);
			evals.addAll(evalBuilder
				.setInvolvedPartyType('PBS; Staff')
				.setCategory('All Others')
				.setSubCategory('Fall')
				.getCommonInstances()
			);

			evals.addAll(evalBuilder
				.setSubCategory('Injury')
				.getCommonInstances()
			);
			Eval__c injuryCause = evalBuilder
				.setHtmlId('injuryCause')
				.setFieldName('injuryCause')
				.setFieldType('Multiselect')
				.setFieldSubType('Checkbox')
				.getInstance();
			Eval__c medTreatment = evalBuilder
				.setRequired(true)
				.setFieldName('medTreatment1')
				.setHtmlId('medTreatment1')
				.setFieldType('Boolean')
				.setFieldSubType('Dropdown')
				.setVisibilityRules('{&quot;1&quot;: [&quot;medTreatmentType1&quot;,&quot;medTreatmentReason&quot;,&quot;treatmentOther&quot;]}')
				.getInstance();
			Eval__c injurySeverity = evalBuilder
				.setEvalType('Involved Party Qualifying')
				.setRequired(false)
				.setVisibilityRules('')
				.setHtmlId('qinjurySeverity')
				.setFieldName('qinjurySeverity')
				.setFieldType('Dropdown')
				.setFieldSubType('')
				.getInstance();
			evals.addAll(new Eval__c[] {
				injuryCause,
				medTreatment,
				injurySeverity,
				evalBuilder
					.setEvalType('Involved Party')
					.setHtmlId('dummyInt')
					.setFieldName('dummyInt')
					.setFieldType('Int')
					.getInstance(),
				evalBuilder
					.setHtmlId('dummyDate')
					.setFieldName('dummyDate')
					.setFieldType('Date')
					.getInstance(),
				evalBuilder
					.setHtmlId('dummyDateTime')
					.setFieldName('dummyDateTime')
					.setFieldType('DateTime')
					.getInstance()
			});
			insert evals;

			TestUtils.EvalDropdownBuilder dropdownBuilder = new TestUtils.EvalDropdownBuilder();
			Eval_Drop_Down__c[] dropdowns = new Eval_Drop_Down__c[]{
				dropdownBuilder
					.setEvalType('Involved Party')
					.setCategory('All Others')
					.setSubCategory('Injury')
					.setHtmlId('injuryCause')
					.setOptionName('Fall')
					.setOptionValue('Fall')
					.getInstance(),
				dropDownBuilder
					.setOptionName('Restraint')
					.setOptionValue('Restraint')
					.incrementSequence()
					.getInstance(),
				dropDownBuilder
					.setEvalType('Involved Party Qualifying')
					.setHtmlId('qinjurySeverity')
					.setSequence(1)
					.setOptionName('Minor')
					.setOptionValue('Minor')
					.getInstance(),
				dropDownBuilder
					.setOptionName('Moderate')
					.setOptionValue('Moderate')
					.incrementSequence()
					.getInstance()
			};
			insert dropdowns;
		}
	}

	public static testmethod void testCloneIncidents() {
		Service_Location__c serviceLocation = [SELECT Id FROM Service_Location__c];
		User qualifier = [SELECT Id FROM User WHERE Email='qualifier@tmn.com'];

		System.runAs(qualifier) {
			Tmn_User__c reviewer = [
				SELECT Id
				  FROM Tmn_User__c
				 WHERE Email__c = 'reviewer@tmn.com'
			];
			Im_Incident__c event = new Im_Incident__c(
				Status__c = 'Event-Draft',
				Service_Location__c = serviceLocation.Id,
				What_Happened__c = 'Random Stuff',
				When_Did_It_Happen__c = DateTime.now().addDays(-2),
				When_Was_the_Supervisor_Notified__c = DateTime.now().addDays(-1),
				Supervisor_for_Location__c = reviewer.Id
			);
			insert event;
			Im_InvolvedParty__c involvedPbs = new Im_InvolvedParty__c(
				Im_Incident__c = event.Id,
				Person_Being_Served_Involved__c = [SELECT Id FROM Service_Assignment__c].Id,
				Nickname__c = 'Test PBS',
				Type__c = 'Person Being Served'
			);
			insert involvedPbs;
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
			event.Status__c = 'Event-Submitted';
			update event;
			Im_InvolvedParty__c party = [
				SELECT Id
				  FROM Im_InvolvedParty__c
				 WHERE Im_Incident__r.Status__c = 'Event-Qualifying'
			];
			Eval_Value__c[] vals = [
				SELECT Id, Boolean__c
				  FROM Eval_Value__c
				 WHERE What_Id__c = :party.Id
				   AND Eval__r.HtmlId__c = 'IsValid'
			];
			for (Eval_Value__c val: vals) {
				System.assertEquals(false, val.Boolean__c);
			}
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
				valueBuilder
					.setCategory('Allegations of Abuse/Neglect')
					.setSubCategory('Allegation of Neglect')
					.setHtmlId('IsValid')
					.setValue(true)
					.getInstance(),
				valueBuilder
					.setSubCategory('Allegation of Abuse - Physical')
					.getInstance(),
				valueBuilder
					.setSubCategory('Allegation of Abuse - Sexual')
					.getInstance(),
				valueBuilder
					.setCategory('Behavioral')
					.setSubCategory('Sexual Aggression/Assault')
					.getInstance(),
				valueBuilder
					.setCategory('Intervention')
					.setSubCategory('Seclusion')
					.getInstance(),
				valueBuilder
					.setCategory('All Others')
					.setSubCategory('Death')
					.getInstance(),
				valueBuilder
					.setSubCategory('Medical Attention')
					.getInstance(),
				valueBuilder
					.setSubCategory('Injury')
					.getInstance()
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
			System.assertNotEquals('', controller.incident.Calculated_Level__c);
			System.assertNotEquals('', controller.incident.Calculated_Level_Explanation__c);
			System.assertEquals('Incident-Draft', controller.incident.Status__c);

			// Update the event here
			valueBuilder = valueBuilder
				.setEvalType('Involved Party')
				.setWhatIdObject('Im_InvolvedParty__c')
				.setWhatId(involvedPbs.Id);
			String isValidValue = valueBuilder
				.setCategory('Allegations of Abuse/Neglect')
				.setSubCategory('Allegation of Neglect')
				.setHtmlId('IsValid')
				.setValue(false)
				.getInstanceJson();

			IncidentManagement.saveFields(involvedPbs.Id, '[' + isValidValue + ']');
			Eval_Value__c value = [
				SELECT Id, Boolean__c
				  FROM Eval_Value__c
				 WHERE Eval__c = :valueBuilder.getInstance().Eval__c
				   AND What_Id__c = :involvedPbs.Id
			];
			System.assertEquals(false, value.Boolean__c);
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

	public static testMethod void testPdf() {
		Service_Location__c serviceLocation = [SELECT Id FROM Service_Location__c];
		User qualifier = [SELECT Id FROM User WHERE Email='qualifier@tmn.com'];

		System.runAs(qualifier) {
			Im_Incident__c incident = new Im_Incident__c(
				Name = 'I-0000000000',
				Status__c = 'Incident-Draft',
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
					.getInstance(),
				valueBuilder
					.setSubCategory('Allegation of Abuse - Physical')
					.getInstance(),
				valueBuilder
					.setSubCategory('Allegation of Abuse - Sexual')
					.getInstance(),
				valueBuilder
					.setCategory('Behavioral')
					.setSubCategory('Sexual Aggression/Assault')
					.getInstance(),
				valueBuilder
					.setCategory('Intervention')
					.setSubCategory('Seclusion')
					.getInstance(),
				valueBuilder
					.setCategory('All Others')
					.setSubCategory('Death')
					.getInstance(),
				valueBuilder
					.setSubCategory('Medical Attention')
					.getInstance(),
				valueBuilder
					.setSubCategory('Injury')
					.getInstance(),
				valueBuilder
					.setHtmlId('medTreatment1')
					.setValue('1')
					.getInstance(),
				valueBuilder
					.setHtmlId('dummyDate')
					.setValue(DateTime.now())
					.getInstance(),
				valueBuilder
					.setHtmlId('dummyDateTime')
					.setValue(DateTime.now())
					.getInstance(),
				valueBuilder
					.setHtmlId('dummyInt')
					.setValue(3)
					.getInstance(),
				valueBuilder
					.setEvalType('Involved Party Qualifying')
					.setHtmlId('qinjurySeverity')
					.setValue('Minor')
					.getInstance()
			};
			insert values;

			Im_EventSummary controller = new Im_EventSummary(new Im_Report_Incident(incident.Id));
			System.assertEquals(1, controller.invPrties.size());
		}
	}

	public static testMethod void testEvalsInDepth() {
		Service_Location__c serviceLocation = [SELECT Id FROM Service_Location__c];
		User qualifier = [SELECT Id FROM User WHERE Email='qualifier@tmn.com'];

		System.runAs(qualifier) {
			Im_Incident__c incident = new Im_Incident__c(
				Name = 'E-0000000001Q',
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
			Im_InvolvedParty__c involvedStaff = new Im_InvolvedParty__c(
				Im_Incident__c = controller.incident.Id,
				Staff_Involved__c = [SELECT Id FROM Tmn_User__c WHERE Salesforce_User_Account__c = :UserInfo.getUserId()].Id,
				Nickname__c = 'Test Staff',
				Type__c = 'Staff'
			);
			insert involvedStaff;
			String eventTypes = IncidentManagement.getInvolvedPartyEventTypes('{ "involvedParty": "' + involvedStaff.Id + '", "involvedPartyType": "Staff" }');
			System.assert(eventTypes.indexOf('Injury') != -1);

			Eval__c[] evals = [
				SELECT Id, HtmlId__c
				  FROM Eval__c
				 WHERE Category__c = 'All Others'
				   AND Sub_Category__c = 'Injury'
			];
			Map<String, Eval__c> evalMap = new Map<String, Eval__c>();
			for (Eval__c eval: evals) {
				evalMap.put(eval.HtmlId__c, eval);
			}

			TestUtils.EvalValueBuilder valueBuilder = new TestUtils.EvalValueBuilder();
			valueBuilder = valueBuilder
				.setEvalType('Involved Party')
				.setWhatIdObject('Im_InvolvedParty__c')
				.setWhatId(involvedStaff.Id);
			String[] values = new String[]{
				valueBuilder
					.setCategory('All Others')
					.setSubCategory('Injury')
					.setHtmlId('IsValid')
					.setValue(true)
					.getInstanceJson(),
				valueBuilder
					.setHtmlId('injuryCause')
					.setValue('Fall')
					.getInstanceJson(),
				valueBuilder
					.setHtmlId('medTreatment1')
					.setValue('1')
					.getInstanceJson(),
				valueBuilder
					.setEvalType('Involved Party Qualifying')
					.setHtmlId('qinjurySeverity')
					.setValue('Minor')
					.getInstanceJson()
			};
			IncidentManagement.saveFields(involvedStaff.Id, '[' + String.join(values, ', ') + ']');

			List<String> partyDetails = IncidentManagement.getEventDetails(involvedStaff.Id, false);
			System.assertNotEquals(0, partyDetails.size());
		}
	}
}