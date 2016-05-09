public with sharing class IncidentModel {
	public enum Stage { EVENT, QUALIFYING, INCIDENT, RESPONSE }

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
				WhatId = incident.Id
			));
		}
		insert newTasks;
		return newTasks;
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
}