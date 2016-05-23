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

	public static void updateNames(Im_Incident__c[] incidents, Map<Id, Im_Incident__c> oldIncidentMap) {
		Map<Id, Im_Incident__c> incidentMap = new Map<Id, Im_Incident__c>(incidents);
		Im_Incident__c[] incidentsToUpdate = new Im_Incident__c[]{};

		incidents = [
			SELECT Id, Status__c, Identifier__c, ReportedEvent__r.Identifier__c
			  FROM Im_Incident__c
			 WHERE Id IN :incidentMap.keySet()
		];
		for (Im_Incident__c incident: incidents) {
			if (oldIncidentMap == null || (oldIncidentMap.containsKey(incident.Id) && oldIncidentMap.get(incident.Id).Status__c != incident.Status__c)) {
				incidentsToUpdate.add(updateName(incident));
			}
		}
		update incidentsToUpdate;
	}

	/**
	 * Determine the name for an incident.
	 */
	private static Im_Incident__c updateName(Im_Incident__c incident) {
		String name = '';

		Boolean isEvent = incident.Status__c.indexOf('Event') != -1;
		Boolean isQualifying = incident.Status__c.indexOf('Qualifying') != -1;

		if (isEvent) {
			name += 'E';
		} else {
			name += 'I';
		}
		name += '-';
		if (incident.ReportedEvent__c != null) {
			name += incident.ReportedEvent__r.Identifier__c;
		} else {
			name += incident.Identifier__c;
		}
		if (isEvent && isQualifying) {
			name += 'Q';
		} else if (isEvent) {
			name += 'R';
		}
		incident.Name = name;
		return incident;
	}

	public static Im_Incident__c finalizeIncident(Im_Incident__c incident, Id userId) {
		TMN_User__c user = [ SELECT Id FROM TMN_User__c WHERE Salesforce_User_Account__c = :userId ];
		incident.Status__c = 'Incident-Finalized';
		incident.eSigned_By__c = user.Id;
		incident.eSigned_Time__c = DateTime.now();
		update incident;
		lockIncidents(new Id[] { incident.Id });
		deleteAllExistingTasks(new Im_Incident__c[] { incident });
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

	public static void deleteExistingReadyForReviewTasks(Im_Incident__c[] incidents) {
		delete [
			SELECT Id
			  FROM Task
			 WHERE Subject = :TASK_FINALIZATION_MSG
			   AND WhatId IN :incidents
		];
	}

	public static void deleteAllExistingTasks(Im_Incident__c[] incidents) {
		delete [ SELECT Id FROM Task WHERE WhatId IN :incidents ];
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

	private class CalculatedLevel {
		public String[] explanationLineItems { get; set; }
		public Integer level { get; set; }

		public CalculatedLevel() {
			this.level = 0;
			this.explanationLineItems = new String[] {};
		}

		public void addExplanation(String lineItem) {
			this.explanationLineItems.add(lineItem);
		}

		public override String toString() {
			return String.valueOf(level) + ' - ' + String.join(explanationLineItems, ', ');
		}
	}

	public static void updateCalculatedLevel(Id involvedPartyId) {
		Im_Incident__c incident = [
			SELECT Id, Status__c
			  FROM Im_Incident__c
			 WHERE Id IN (SELECT Im_Incident__c FROM Im_InvolvedParty__c WHERE Id = :involvedPartyId)
		];
		if (incident.Status__c.indexOf('Incident') != -1) {
			Map<Id, Im_InvolvedParty__c> allInvolvedParties = new Map<Id, Im_InvolvedParty__c>([
				SELECT Id FROM Im_InvolvedParty__c WHERE Im_Incident__c = :incident.Id
			]);
			Eval_Value__c[] allEvalValues = [
				SELECT Id, Eval_Section_Id__c, Text_Under_250__c, Number_No_Decimal__c, Date_Time__c,
				       Eval__r.Category__c, Eval__r.Sub_Category__c, Eval__r.htmlid__c, Boolean__c,
				       Eval__r.Eval_Type__r.Name
				  FROM Eval_Value__c
				 WHERE What_Id__c IN :allInvolvedParties.keySet()
				];
			updateCalculatedLevel(incident.Id, allEvalValues);
		}
	}

	public static void updateCalculatedLevel(Id incidentId, Eval_Value__c[] values) {
		System.debug('updateCalculatedLevel called for incident ' + incidentId + ' with values: ' + values);
		Integer level = 0;
		String explanation = '';
		Map<String, CalculatedLevel> sectionLevelMap = new Map<String, CalculatedLevel>();
		// Put all of the values into different "buckets" based on their eval section id
		Map<String, Eval_Value__c[]> sectionMap = new Map<String, Eval_Value__c[]>();

		for (Eval_Value__c value: values) {
			if (value.Eval__r.Eval_Type__r.Name != 'Involved Party' && value.Eval__r.Eval_Type__r.Name != 'Involved Party Qualifying') {
				continue;
			}
			// String composite = value.Eval__r.Composite__c + '~' + value.Eval_Section_Id__c;
			if (!sectionMap.containsKey(value.Eval_Section_Id__c)) {
				sectionMap.put(value.Eval_Section_Id__c, new List<Eval_Value__c>());
			}
			sectionMap.get(value.Eval_Section_Id__c).add(value);
		}

		for (String evalSectionId: sectionMap.keySet()) {
			Eval_Value__c[] sectionValues = sectionMap.get(evalSectionId);
			// First let's create a map from the htmlid to the values for easy access
			Map<String, Eval_Value__c> valueMap = new Map<String, Eval_Value__c>();
			for (Eval_Value__c value: sectionValues) {
				valueMap.put(value.Eval__r.HtmlId__c, value);
			}

			// Only count a section to be eligible for leveling if it's fully filled out
			if (!valueMap.containsKey('IsValid') || !valueMap.get('IsValid').Boolean__c) {
				continue;
			}

			String sectionName = sectionValues[0].Eval__r.Category__c + '~' + sectionValues[0].Eval__r.Sub_Category__c;
			CalculatedLevel sectionLevel;
			if (!sectionLevelMap.containsKey(sectionName)) {
				sectionLevel = new CalculatedLevel();
				sectionLevelMap.put(sectionName, sectionLevel);
			} else {
				sectionLevel = sectionLevelMap.get(sectionName);
			}

			// The following sections are easy, since we don't have to delve into the values themselves.
			if (sectionName == 'Allegations of Abuse/Neglect~Allegation of Neglect') {
				sectionLevel.level = 3;
			} else if (sectionName == 'Allegations of Abuse/Neglect~Allegation of Abuse - Physical') {
				sectionLevel.level = 3;
			} else if (sectionName == 'Allegations of Abuse/Neglect~Allegation of Abuse - Sexual') {
				sectionLevel.level = 3;
			} else if (sectionName == 'Behavioral~Sexual Aggression/Assault') {
				sectionLevel.level = 3;  // TODO at the point of this writing this category doesn't exist yet
			} else if (sectionName == 'Intervention~Seclusion') {
				sectionLevel.level = 3;
			} else if (sectionName == 'All Others~Death') {
				sectionLevel.level = 4;
			} else if (sectionName == 'All Others~Medical Attention') {
				sectionLevel.level = 3;  // TODO check this, at the point of this writing, the data still has Medical Attention as the Category, instead of All Others
			}
			if (sectionLevel.level != 0) {
				sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for ' + sectionName);
				continue;
			}

			// Now we have to go into the eval values and determine the levels
			System.debug('sectionName: ' + sectionName);
			System.debug('valueMap: ' + valueMap);
			System.debug('valueMap keySet: ' + valueMap.keySet());
			if (sectionName == 'Allegations of Abuse/Neglect~Allegation of Abuse - Financial Exploitation') {
				if (!valueMap.containsKey('valueKnown') || !valueMap.containsKey('neglectAmount')) {
					continue;
				}
				if (valueMap.get('valueKnown').Text_Under_250__c == '1') {
					if (valueMap.get('neglectAmount').Text_Under_250__c.indexOf('Greater') != -1) {
						sectionLevel.level = 3;
						sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Financial Exploitation greater than $30');
					} else {
						sectionLevel.level = 2;
						sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Financial Exploitation less than $30');
					}
				}
			} else if (sectionName == 'Allegations of Abuse/Neglect~Allegation of Abuse - Emotional/Verbal') {
				// TODO recheck if leader question 3 is Was Law Enforcement Involved
				if (!valueMap.containsKey('lawEnforcement') || valueMap.get('lawEnforcement').Text_Under_250__c != '1') {
					sectionLevel.level = 2;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Allegation of Emotional/Verbal Abuse without law enforcement involved');
				} else {
					sectionLevel.level = 3;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Allegation of Emotional/Verbal Abuse with law enforcement involved');
				}
			} else if (sectionName == 'Behavioral~Missing Person/Elopement') {
				// TODO check what State Regulation is
				if (!valueMap.containsKey('elopeFound24') || !valueMap.containsKey('injuryPresent')) {
					continue;
				}
				if (valueMap.get('elopeFound24').Text_Under_250__c == '0') {
					sectionLevel.level = 3;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Missing Person not located at time of report');
				} else if (valueMap.get('injuryPresent').Text_Under_250__c == '1') {
					sectionLevel.level = 3;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for located Missing Person with injury');
				} else {
					sectionLevel.level = 2;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for located Missing Person');
				}
			} else if (sectionName == 'Behavioral~Physical Aggression') {
				// TODO check what State Regulation is
				// TODO check what Medical + Injury means
				// TODO check what Other Involved Party means
			} else if (sectionName == 'Behavioral~Inappropriate Sexual Behavior') {
				// TODO check what State Regulation is
				// TODO check what Medical + Injury means
				// TODO check what Other Involved Party means
			} else if (sectionName == 'Behavioral	Threat of Violence/Assault') {
				// TODO check what State Regulation is
				// TODO check what Medical + Injury means
				// TODO check what Other Involved Party means
			} else if (sectionName == 'Behavioral~Theft by Person Being Served') {

			} else if (sectionName == 'Behavioral~Law Enforcement Involvement') {

			} else if (sectionName == 'Behavioral~Gang Involvement') {

			} else if (sectionName == 'Behavioral~PICA') {

			} else if (sectionName == 'Behavioral~Self Injury') {

			} else if (sectionName == 'Intervention~Physical Restraint') {

			} else if (sectionName == 'Intervention~Mechanical Restraint') {

			} else if (sectionName == 'Intervention~Chemical Restraint') {

			} else if (sectionName == 'Medication~Medication Error') {

			} else if (sectionName == 'Medication~Medication Refusal') {

			} else if (sectionName == 'Medication~Other Medication Related Event') {

			} else if (sectionName == 'Medication~Serious Adverse Effect Related to Medication') {

			} else if (sectionName == 'Mental Health~Ingestion of Foreign Object') {
				if (!valueMap.containsKey('injuryPresent') || !valueMap.containsKey('medTreatment1') || !valueMap.containsKey('lawEnforcement')) {
					continue;
				}
				if (valueMap.get('injuryPresent').Text_Under_250__c == '1' || valueMap.get('medTreatment1').Text_Under_250__c == '1' || valueMap.get('lawEnforcement').Text_Under_250__c == '1') {
					sectionLevel.level = 3;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Ingestion of Foreign Object with Injury, Law Enforcement involvement or Medical Attention');
				} else {
					sectionLevel.level = 2;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Ingestion of Foreign Object with no Injury, Law Enforcement involvement or Medical attention');
				}
			} else if (sectionName == 'Mental Health~Self Harm') {
				if (!valueMap.containsKey('injuryPresent') || !valueMap.containsKey('medTreatment1') || !valueMap.containsKey('lawEnforcement')) {
					continue;
				}
				if (valueMap.get('injuryPresent').Text_Under_250__c == '1' || valueMap.get('medTreatment1').Text_Under_250__c == '1' || valueMap.get('lawEnforcement').Text_Under_250__c == '1') {
					sectionLevel.level = 3;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Self Harm with Injury, Law Enforcement involvement or Medical Attention');
				} else {
					sectionLevel.level = 2;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Self Harm with no Injury, Law Enforcement involvement or Medical attention');
				}
			} else if (sectionName == 'Mental Health~Homicide') {

			} else if (sectionName == 'Mental Health~Possession of Weapon') {
				if (!valueMap.containsKey('injuryPresent') || !valueMap.containsKey('medTreatment1') || !valueMap.containsKey('lawEnforcement')) {
					continue;
				}
				if (valueMap.get('injuryPresent').Text_Under_250__c == '1' || valueMap.get('medTreatment1').Text_Under_250__c == '1' || valueMap.get('lawEnforcement').Text_Under_250__c == '1') {
					sectionLevel.level = 3;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Possession of Weapon with Injury, Law Enforcement involvement or Medical Attention');
				} else {
					sectionLevel.level = 2;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Possession of Weapon with no Injury, Law Enforcement involvement or Medical attention');
				}
			} else if (sectionName == 'Mental Health~Possession of Pornography') {

			} else if (sectionName == 'Mental Health~Possession of Alcohol') {

			} else if (sectionName == 'Mental Health~Possession of Drugs (Controlled Substance)') {

			} else if (sectionName == 'Mental Health~Mental Health Decompensation') {

			} else if (sectionName == 'All Others~Injury') {

			} else if (sectionName == 'Fall~Fall') {
				// TODO in spreadsheet this is All Others~Fall
				// TODO no Injury question in here yet
				if (!valueMap.containsKey('injuryPresent') || !valueMap.containsKey('medTreatment1')) {
					continue;
				}
				if (valueMap.get('injuryPresent').Text_Under_250__c == '1' || valueMap.get('medTreatment1').Text_Under_250__c == '1') {
					sectionLevel.level = 3;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Fall with Injury or Medical Attention');
				} else {
					sectionLevel.level = 2;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Fall with no Injury or Medical attention');
				}
			} else if (sectionName == 'All Others~Medical Event') {
				// TODO doesn't exist in data yet
			} else if (sectionName == 'Medical Attention~Medical Attention') {
				// TODO in spreadsheet this is All Others~Medical Attention
			} else if (sectionName == 'All Others~Vehicle Accident') {
				if (!valueMap.containsKey('injuryPresent') || !valueMap.containsKey('medTreatment1')) {
					continue;
				}
				if (valueMap.get('injuryPresent').Text_Under_250__c == '1' || valueMap.get('medTreatment1').Text_Under_250__c == '1') {
					sectionLevel.level = 3;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Vehicle Accident with Injury or Medical Attention');
				} else {
					sectionLevel.level = 2;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Vehicle Accident with no Injury or Medical attention');
				}
			} else if (sectionName == 'All Others~Exposure to Substance') {
				if (!valueMap.containsKey('injuryPresent') || !valueMap.containsKey('medTreatment1')) {
					continue;
				}
				if (valueMap.get('medTreatment1').Text_Under_250__c == '1' && valueMap.get('injuryPresent').Text_Under_250__c == '0') {
					sectionLevel.level = 3;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Exposure to Substance with Medical Attention but no injury');
				} else if (valueMap.get('medTreatment1').Text_Under_250__c == '1' && valueMap.get('injuryPresent').Text_Under_250__c == '1') {
					sectionLevel.level = 4;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Exposure to Substance with Medical Attention and injury');
				} else {
					sectionLevel.level = 2;
					sectionLevel.addExplanation('Level ' + sectionLevel.level + ' for Exposure to Substance');
				}
			} else if (sectionName == 'All Others~Emergency Relocation') {

			}
		}

		// Reduce all the section levels into one level and one full explanation
		if (sectionLevelMap.size() != 0) {
			for (String sectionName: sectionLevelMap.keySet()) {
				CalculatedLevel sectionLevel = sectionLevelMap.get(sectionName);
				System.debug(sectionName + ': ' + sectionLevel);
				if (sectionLevel.level == 0) {
					continue;
				}
				if (level < sectionLevel.level) {
					level = sectionLevel.level;
				}
				explanation += String.join(sectionLevel.explanationLineItems, '\n') + '\n';
			}
			if (explanation != '') {
				explanation = 'The calculated level is the highest value among the following line items: \n\n' + explanation;
			}
			System.debug(explanation);
		}
		update new Im_Incident__c(
			Id = incidentId,
			Calculated_Level__c = String.valueOf(level),
			Calculated_Level_Explanation__c = explanation
		);
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
		Set<String> allInvolvedPartyTypes = new Set<String>();
		for (Id involvedPartyId: invPrties.keySet()) {
			allInvolvedPartyTypes.add(invPrties.get(involvedPartyId).Type__c);
		}
		if (invPrties.keySet().size() == 0) {
			myValidationErrors.add('There are no involved parties added. At least one involved party with all the event types associated is required. Please update and try again.');
			validationResults.put('validationErrors', myValidationErrors);
			return validationResults;
		}
		map<String, list<Eval_Value__c>> sectionsMap = new map<String, list<Eval_Value__c>>();
		List<Eval_Value__c> allEvalVals = [
			SELECT id, boolean__c, text_over_250__c, eval__c, eval__r.sub_category__c,
			       eval_section_id__c, eval__r.htmlId__c, what_id__c, text_under_250__c
			  FROM Eval_Value__c
			 WHERE eval__r.Visible__c = true
			   AND what_id__c IN : invPrties.keySet()
			ORDER BY what_id__c, eval__r.category_sequence__c, eval__r.sub_category_sequence__c,
			         eval__r.Field_sequence__c
		];
		List<Eval_Value__c> evalVals = new List<Eval_Value__c>();
		for (Eval_Value__c value: allEvalVals) {
			if (value.Eval__r.HtmlId__c == 'ErrorMsg' || value.Eval__r.HtmlId__c == 'IsValid') {
				evalVals.add(value);
			}
		}

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

		// Sometimes certain involved party types are required, so we use these booleans to track them
		Boolean staffInvolvedPartyNeeded = false;
		Boolean mentorInvolvedPartyNeeded = false;
		Boolean otherInvolvedPartyNeeded = false;
		// These are the fields that have the Against Whom values we need to use for validation.
		// This is generated by the query:
		// SELECT Id, category__c, sub_category__c, field_name__c, htmlid__c FROM Eval__c where eval_type__r.name LIKE 'Involved Party%' AND field_name__c LIKE '%Against%' ORDER BY category_sequence__c, sub_category_sequence__c, field_sequence__c
		// TODO there are more fields to add here once the data get completed
		Set<String> htmlIdsToCheck = new Set<String>{
			'againstPBSphys',
			'againstPBSfin',
			'againstPBSsx',
			'againstPBSemot',
			'againtsPhysAgg'
		};
		for (Eval_Value__c value: allEvalVals) {
			if (htmlIdsToCheck.contains(value.eval__r.htmlId__c)) {
				if (value.Text_Under_250__c == 'Staff') {
					staffInvolvedPartyNeeded = true;
				} else if (value.Text_Under_250__c.startsWith('Mentor')) {  // TODO check if mentor/Host Home Family Member should be included here
					mentorInvolvedPartyNeeded = true;
				} else if (value.Text_Under_250__c.startsWith('Other')) {
					otherInvolvedPartyNeeded = true;
				}
			}
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
		if (staffInvolvedPartyNeeded && !allInvolvedPartyTypes.contains('Staff')) {
			myValidationErrors.add('You need to have at least 1 involved party with type Staff');
		}
		if (otherInvolvedPartyNeeded && !allInvolvedPartyTypes.contains('Other')) {
			myValidationErrors.add('You need to have at least 1 involved party with type Other');
		}
		// TODO add Mentor involved party type validation, since now we don't have
		// a Mentor Involved Party type (it's called Host Home Parent)
		if (myValidationErrors.size() > 0){
			validationResults.put('validationErrors', myValidationErrors);
			return validationResults;
		}

		validationResults.put('goodToSubmit', true);
		return validationResults;
	}
}