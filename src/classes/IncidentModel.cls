public with sharing class IncidentModel {
	public enum Stage { EVENT, QUALIFYING, INCIDENT, REVIEW, RESPONSE }

	public static final Id TASK_RECORD_TYPE = Schema.SObjectType.Task.getRecordTypeInfosByName()
		.get('Incident Management').getRecordTypeId();

	public static Boolean checkLocked(IncidentModel.Stage stage, Im_Incident__c incident) {
		if (incident.Id == null) {
			return false;
		}
		if (stage == IncidentModel.Stage.EVENT) {
			// if the event is disregarded or submitted
			// OR this is the event that is a result of of an event submit
			// OR if there is a lock on the event because of its submit
			return incident.Status__c == 'Event-Submitted'
				|| incident.Status__c == 'Event-Disregarded'
				|| String.IsNotBlank(incident.ReportedEvent__c)
				|| Approval.isLocked(incident.Id);
		} else if (stage == IncidentModel.Stage.QUALIFYING) {
			return incident.Status__c == 'Event-Closed'
				|| Approval.isLocked(incident.Id);
		} else if (stage == IncidentModel.Stage.INCIDENT) {
			return incident.Status__c == 'Incident-Final'
				|| incident.Status__c == 'Incident-Disregarded'
				|| Approval.isLocked(incident.Id);
		} else {
			return false;
		}
	}

	public static Im_Incident__c finalizeIncident(Im_Incident__c incident, Id userId) {
		TMN_User__c user = [ SELECT Id FROM TMN_User__c WHERE Salesforce_User_Account__c = :userId ];
		incident.Status__c = 'Incident-Finalized';
		incident.eSigned_By__c = user.Id;
		incident.eSigned_Time__c = DateTime.now();
		update incident;
		lockIncidents(new Id[] { incident.Id });
		return incident;
	}

	public static Boolean lockIncidents(List<Id> incidents) {
		List<id> idsToLock = incidents.clone();
		Map<Id, Im_InvolvedParty__c> involvedParties = new Map<Id, Im_InvolvedParty__c>(
			[select id from Im_involvedParty__c where Im_Incident__c IN :incidents]
		);
		idsToLock.addAll(involvedParties.keySet());
		Approval.LockResult[] lrList = Approval.lock(idsToLock, false);
		Boolean errorFound = false;

		// Iterate through each returned result
		for(Approval.LockResult lr : lrList) {
			if (lr.isSuccess()) {
				// Operation was successful, so get the ID of the record that was processed
				System.debug('Successfully locked objects with ID: ' + lr.getId());
			} else {
				// Operation failed, so get all errors
				for(Database.Error err : lr.getErrors()) {
					System.debug('The following error has occurred.');
					System.debug(err.getStatusCode() + ': ' + err.getMessage());
					System.debug('incidents fields that affected this error: ' + err.getFields());
					errorFound = true;
				}
			}
		}
		return errorFound;
	}

	public static Task[] createIncidentFinalizationTasks(Im_Incident__c[] incidents) {
		System.debug('create incident finalization tasks for: ' + incidents);
		Task[] newTasks = new Task[]{};
		for (Im_Incident__c incident: incidents) {
			newTasks.add(new Task(
				Status = 'Not Started',
				Subject = 'Please submit the Incident report for review',
				ActivityDate = incident.CreatedDate.addDays(2).date(),
				Priority = 'High',
				OwnerId = incident.OwnerId,
				WhatId = incident.Id,
				RecordTypeId = IncidentModel.TASK_RECORD_TYPE
			));
		}
		insert newTasks;
		return newTasks;
	}

	public static Task[] createEventTasks(Im_Incident__c[] events) {
		System.debug('create event tasks for: ' + events);
		Task[] newTasks = new Task[]{};
		for (Im_Incident__c event: events) {
			newTasks.add(new Task(
				Status = 'Not Started',
				Subject = 'Please complete and submit the Event',
				ActivityDate = event.CreatedDate.addDays(1).date(),
				Priority = 'High',
				OwnerId = event.OwnerId,
				WhatId = event.Id,
				RecordTypeId = IncidentModel.TASK_RECORD_TYPE
			));
		}
		insert newTasks;
		return newTasks;
	}

	public static Task[] createQualifyingTasks(Im_Incident__c[] events) {
		System.debug('create qualifying tasks for: ' + events);
		Task[] newTasks = new Task[]{};
		for (Im_Incident__c event: events) {
			newTasks.add(new Task(
				Status = 'Not Started',
				Subject = 'Please review and complete the Event',
				ActivityDate = event.CreatedDate.addDays(2).date(),
				Priority = 'High',
				OwnerId = event.OwnerId,
				WhatId = event.Id,
				RecordTypeId = IncidentModel.TASK_RECORD_TYPE
			));
		}
		insert newTasks;
		return newTasks;
	}

	private static final String TASK_FINALIZATION_MSG = 'Please review the Incident report';
	public static Task[] createReadyForReviewTasks(Im_Incident__c[] incidents) {
		System.debug('create incident ready for review tasks for: ' + incidents);
		Task[] newTasks = new Task[]{};

		Set<Id> tmnUsers = new Set<Id>();

		for (Im_Incident__c incident: incidents) {
			tmnUsers.add(incident.Incident_Reviewer__c);
		}
		Map<Id, Tmn_User__c> tmnUserMap = new Map<Id, TMN_User__c>(
			[SELECT Id, Salesforce_User_Account__c FROM TMN_User__c WHERE Id IN :tmnUsers]
		);

		for (Im_Incident__c incident: incidents) {
			newTasks.add(new Task(
				Status = 'Not Started',
				Subject = TASK_FINALIZATION_MSG,
				ActivityDate = incident.CreatedDate.addDays(2).date(),
				Priority = 'High',
				OwnerId = tmnUserMap.get(incident.Incident_Reviewer__c).Salesforce_User_Account__c,
				WhatId = incident.Id,
				RecordTypeId = IncidentModel.TASK_RECORD_TYPE
			));
		}
		insert newTasks;
		return newTasks;
	}

	public static void deleteExistingReadyForReviewTask(Im_Incident__c incident) {
		// Assumption: if the user changes the Incident Reviewer, the task assigned to the original
		// reviewer will *not* be deleted
		delete [
			SELECT Id
			  FROM Task
			 WHERE Subject = :TASK_FINALIZATION_MSG
			   AND WhatId = :incident.Id
		];
	}

	/**
	 * Find reviewers for a certain state.
	 * @param the name of the reviewer to search for.
	 * @param state a 2 letter abbreviation for a state.
	 * @return a list of Tmn_User__c who can review an incident.
	 */
	public static Tmn_User__c[] findReviewers(String query, String state) {
		return [
			SELECT Id, Name, Job_Title__c, Email__c
			  FROM Tmn_User__c
			 WHERE Approval_Level__c >= 4
			   AND Salesforce_User_Account__c != null
				 AND Salesforce_User_Account__c != :UserInfo.getUserId()
				 AND Job_Status__c = 'Active'
			   AND Alias_Lookup__r.Alias_State__c = :state
			   AND Name LIKE :query
		];
	}

	public static void cloneIncidents(Map<Id,Im_Incident__c> incidentsToClone) {
		list<String> selectFields = new list<string>();
		set<Id> incidentIds = incidentsToClone.keySet();
		Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe()
			.get('Im_Incident__c').getDescribe().Fields.getMap();
		if (fMap != null) {
			for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
				Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
				selectFields.add(fd.getName());
			}
		}
		selectFields.addAll(
			new List<String> { 'Supervisor_for_Location__r.Salesforce_User_Account__c' }
		);

		list<String> selectFields2 = new list<string>();
		Map<String, Schema.SObjectField> fMap2 = Schema.getGlobalDescribe().get('Im_InvolvedParty__c').getDescribe().Fields.getMap();
		if (fMap2 != null) {
			for (Schema.SObjectField ft : fMap2.values()){ // loop through all field tokens (ft)
				Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
				selectFields2.add(fd.getName());
			}
		}
		String strSQL =  'SELECT ' + String.join(selectFields, ',')
			+ ', (SELECT ' + String.join(selectFields2, ',')
			+ ' FROM Im_InvolvedParties__r )'
			+ ' FROM Im_Incident__c WHERE Id IN :incidentIds ';
		system.debug('Incident clone strSQL: ' + strSQL);
		list<Im_Incident__c> incidents = Database.query(strSQL);

		map<id,Im_InvolvedParty__c> oldToNewInvPrtyMap = new map<id,Im_InvolvedParty__c>();
		for (Im_Incident__c incident : incidents){
			//clone(Boolean preserveId, Boolean isDeepClone, Boolean preserveReadonlyTimestamps, Boolean preserveAutonumber)
			Im_Incident__c incidentClone = incident.clone(false, true, false, false);
			incidentClone.Status__c = 'Event-Qualifying';
			incidentClone.ReportedEvent__c = incident.id; // the orignal incident reported
			incidentClone.OwnerId = incident.Supervisor_for_Location__r.Salesforce_User_Account__c; // we need to do this so that the task is created for this user
			insert incidentClone;
			for(Im_InvolvedParty__c invPrty : incident.Im_InvolvedParties__r){
				Im_InvolvedParty__c involvedParty = invPrty.clone(false, true, false, false);
				involvedParty.Im_Incident__c = incidentClone.id;
				oldToNewInvPrtyMap.put(invPrty.id, involvedParty);
			}
			insert oldToNewInvPrtyMap.values();
		}

		//clone evalValues
		list<String> selectFields3 = new list<string>();
		Map<String, Schema.SObjectField> fMap3 = Schema.getGlobalDescribe()
			.get('Eval_Value__c').getDescribe().Fields.getMap();
		if (fMap3 != null) {
			for (Schema.SObjectField ft : fMap3.values()){ // loop through all field tokens (ft)
				Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
				selectFields3.add(fd.getName());
			}
		}
		Set<Id> invPryIds = new set<Id>(oldToNewInvPrtyMap.keySet());
		String strSQL2 =  'SELECT ' + String.join(selectFields3, ',') + ', Eval__r.HtmlId__c FROM Eval_Value__c WHERE what_id__c IN : invPryIds';
		system.debug('eval_values to clone strSQL: ' + strSQL2);
		list<Eval_Value__c> evalValues = Database.query(strSQL2);

		list<Eval_Value__c> evalValuesClones = new list<Eval_Value__c>();
		for(Eval_Value__c ev : evalValues){
			Eval_Value__c evClone = ev.clone(false, true, false, false);
			if (evClone.eval__r.htmlId__c.equalsIgnoreCase('isValid')) {
				// Turn all the sections to invalid, since there will be additional Qualifier questions
				evClone.Boolean__c = false;
			}
			evClone.what_id__c = oldToNewInvPrtyMap.get(ev.what_id__c).id;
			evalValuesClones.add(evClone);
		}
		insert evalValuesClones;

		// clone evaluation responses - for the body map annotations
		list<Evaluation_Response__c> evalResponsesClone = new list<Evaluation_Response__c>();
		for(Evaluation_Response__c evalResp : [
				SELECT ID, Annotation_Height__c, Annotation_Width__c, Annotation_X__c,
				       Annotation_Y__c, Annotation_Source__c, Annotation_Shape__c,
				       Annotation_Text__c, ImInvolvedPartyAnnotations__c
				  FROM Evaluation_Response__c WHERE ImInvolvedPartyAnnotations__c IN :oldToNewInvPrtyMap.keySet()
				    AND RecordType.Name = 'Annotation'
		]){
			Evaluation_Response__c evalRespClone = evalResp.clone(false, true, false, false);
			evalRespClone.ImInvolvedPartyAnnotations__c = oldToNewInvPrtyMap.get(evalResp.ImInvolvedPartyAnnotations__c).id;
			evalRespClone.Annotation_Source__c = evalRespClone.Annotation_Source__c.replace(String.ValueOf(evalResp.ImInvolvedPartyAnnotations__c), String.ValueOf(oldToNewInvPrtyMap.get(evalResp.ImInvolvedPartyAnnotations__c).id));
			evalResponsesClone.add(evalRespClone);
		}
		insert evalResponsesClone;
	}

	public static Map<string, object> validateEvent(String eventId) {
		map<string, object> validationResults = new map<string, object>{
			'goodToSubmit' => false,
			'validationErrors' => ''
		};
		list<String> myValidationErrors = new list<String>();

		map<id, Im_InvolvedParty__c> invPrties = new map<id, Im_InvolvedParty__c>([
			SELECT Id, type__c, name, Person_Being_Served_Involved__r.pbsFirstName__c,
			       Person_Being_Served_Involved__r.pbsLastName__c, Staff_Involved__r.name
			  FROM Im_InvolvedParty__c
			 WHERE Im_incident__c =: eventId
		]);
		if (invPrties.keySet().size() == 0) {
			myValidationErrors.add('There are no involved parties added. At least one involved party with all the event types associated is required. Please update and try again.');
			validationResults.put('validationErrors', myValidationErrors);
			return validationResults;
		}
		map<String, list<Eval_Value__c>> sectionsMap = new map<String, list<Eval_Value__c>>();
		list<Eval_Value__c> evalVals = [
			SELECT id, boolean__c, text_over_250__c, eval__c, eval__r.sub_category__c,
			       eval_section_id__c, eval__r.htmlId__c, what_id__c
			  FROM Eval_Value__c
			 WHERE eval__r.Visible__c = true
			   AND what_id__c IN : invPrties.keySet()
			   AND (eval__r.htmlId__c = 'ErrorMsg' OR eval__r.htmlId__c = 'IsValid')
			ORDER BY what_id__c, eval__r.category_sequence__c, eval__r.sub_category_sequence__c,
			         eval__r.Field_sequence__c
		];
		if (evalVals.size() == 0) {
			myValidationErrors.add('At least one event type is required for each involved party. Please update and try again.');
			validationResults.put('validationErrors', myValidationErrors);
			return validationResults;
		}

		set<Id> invPartiesWithEvalVal = new set<Id>();
		for (Eval_Value__c value: evalVals) {
			if (!sectionsMap.containsKey(value.eval_section_id__c)) {
				sectionsMap.put(value.eval_section_id__c, new list<Eval_Value__c>{value});
			} else {
				sectionsMap.get(value.eval_section_id__c).add(value);
			}
			invPartiesWithEvalVal.add((Id)value.what_id__c);
		}

		set<Id> invPrtiesIdClone = invPrties.keySet().clone();
		invPrtiesIdClone.removeAll(invPartiesWithEvalVal);
		if (invPrtiesIdClone.size() > 0) {
			myValidationErrors.add('At least one event type is required for each involved party. No events found for following involved parties:');
			for (Id i : invPrtiesIdClone){
				myValidationErrors.add(invPrties.get(i).type__c + ' - ' + invPrties.get(i).name);
			}
			validationResults.put('validationErrors', myValidationErrors);
			return validationResults;
		}

		for(String section : sectionsMap.keySet()) {
			list<Eval_Value__c> values = sectionsMap.get(section);
			if (values.size() == 1 && values[0].boolean__c == false) { // user never saved the event details
				Eval_Value__c ev = values[0];
				myValidationErrors.add(
					invPrties.get(ev.what_id__c).Type__c + ' - ' +  invPrties.get(ev.what_id__c).Name
					+ '. Event details not filled for : ' + ev.eval__r.sub_category__c
				);
			}
			// user saved the event but there were errors
			if (values.size() > 1 && values[0].boolean__c == false && String.IsNotBlank(values[1].text_over_250__c)) {
				Eval_Value__c ev = values[1];
				myValidationErrors.add(
					invPrties.get(ev.what_id__c).Type__c + ' - ' +  invPrties.get(ev.what_id__c).Name
					+ '. Missing required fields for event : ' + ev.eval__r.sub_category__c
				);
			}
		}
		if (myValidationErrors.size() > 0){
			validationResults.put('validationErrors', myValidationErrors);
			return validationResults;
		}

		validationResults.put('goodToSubmit', true);
		return validationResults;
	}
}