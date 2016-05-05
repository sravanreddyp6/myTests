public without sharing class Im_IncidentTriggerHandler {
    private boolean m_isExecuting = false;
    public Im_IncidentTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }
    public void OnBeforeInsert(Im_Incident__c[] oldObjects, Im_Incident__c[] updatedObjects, Map<Id, Im_Incident__c> oldObjMap, Map<Id,Im_Incident__c> newObjMap){
	}

    public void OnAfterInsert(Im_Incident__c[] oldObjects, Im_Incident__c[] updatedObjects, Map<Id, Im_Incident__c> oldObjMap, Map<Id,Im_Incident__c> newObjMap){

	}

	public void OnAfterUpdate(Im_Incident__c[] oldObjects, Im_Incident__c[] updatedObjects, Map<Id, Im_Incident__c> oldObjMap, Map<Id,Im_Incident__c> newObjMap){
		map<Id, Im_Incident__c> incidentTasksToDel = new Map<Id, Im_Incident__c>();
		map<Id, Im_Incident__c> incidentsToClone = new Map<Id, Im_Incident__c>();
		Im_Incident__c[] qualifiedIncidents = new Im_Incident__c[]{};

		for(Im_Incident__c event : updatedObjects){
			if (event.Status__c == 'Event-Submitted' || event.Status__c == 'Event-Disregarded' || event.Status__c == 'Event-Closed') {
				incidentTasksToDel.put(event.id, event);
			}
			if (event.Status__c == 'Incident-Draft' && oldObjMap.get(event.Id).Status__c != 'Incident-Draft') {
				System.debug('old obj status: ' + oldObjMap.get(event.Id).Status__c);
				incidentTasksToDel.put(event.id, event);
				qualifiedIncidents.add(event);
			}
			if (event.Status__c == 'Event-Submitted') {
				incidentsToClone.put(event.id, event);
			}
		}
		if (incidentTasksToDel.keySet().size() > 0) {
			deleteTasksForIncidents(incidentTasksToDel);
		}
		if (incidentsToClone.keySet().size() > 0) {
			cloneIncidents(incidentsToClone);
		}
		if (qualifiedIncidents.size() > 0) {
			IncidentModel.createIncidentFinalizationTasks(qualifiedIncidents);
		}
	}

	private void deleteTasksForIncidents(Map<Id,Im_Incident__c> incidentTasksToDel){
		list<Task> tasks2del = new list<Task>();
		delete [select id from Task where whatId IN : incidentTasksToDel.keySet()];
	}

	private void cloneIncidents(Map<Id,Im_Incident__c> incidentsToClone){
		list<String> selectFields = new list<string>();
		set<Id> incidentIds = incidentsToClone.keySet();
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('Im_Incident__c').getDescribe().Fields.getMap();
        if (fMap != null) {
        	for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
            	Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                selectFields.add(fd.getName());
            }
		}
		selectFields.addAll(new List<String>{'Supervisor_for_Location__r.Salesforce_User_Account__c'});

		list<String> selectFields2 = new list<string>();
		Map<String, Schema.SObjectField> fMap2 = Schema.getGlobalDescribe().get('Im_InvolvedParty__c').getDescribe().Fields.getMap();
        if (fMap2 != null) {
        	for (Schema.SObjectField ft : fMap2.values()){ // loop through all field tokens (ft)
            	Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                selectFields2.add(fd.getName());
            }
		}
        String strSQL =  'SELECT ' + String.join(selectFields, ',') + ', (SELECT ' + String.join(selectFields2, ',') + ' FROM Im_InvolvedParties__r )' + ' FROM Im_Incident__c WHERE Id IN :incidentIds ';
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
		Map<String, Schema.SObjectField> fMap3 = Schema.getGlobalDescribe().get('Eval_Value__c').getDescribe().Fields.getMap();
        if (fMap3 != null) {
        	for (Schema.SObjectField ft : fMap3.values()){ // loop through all field tokens (ft)
            	Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                selectFields3.add(fd.getName());
            }
		}
		Set<Id> invPryIds = new set<Id>(oldToNewInvPrtyMap.keySet());
        String strSQL2 =  'SELECT ' + String.join(selectFields3, ',') + ' FROM Eval_Value__c WHERE what_id__c IN : invPryIds';
        system.debug('eval_values to clone strSQL: ' + strSQL2);
        list<Eval_Value__c> evalValues = Database.query(strSQL2);

		list<Eval_Value__c> evalValuesClones = new list<Eval_Value__c>();
		for(Eval_Value__c ev : evalValues){
				Eval_Value__c evClone = ev.clone(false, true, false, false);
				evClone.what_id__c = oldToNewInvPrtyMap.get(ev.what_id__c).id;
				evalValuesClones.add(evClone);
		}
		insert evalValuesClones;

		// clone evaluation responses - for the body map annotations
		list<Evaluation_Response__c> evalResponsesClone = new list<Evaluation_Response__c>();
		for(Evaluation_Response__c evalResp : [SELECT ID, Annotation_Height__c, Annotation_Width__c, Annotation_X__c,
												       Annotation_Y__c, Annotation_Source__c, Annotation_Shape__c,
												       Annotation_Text__c, ImInvolvedPartyAnnotations__c
												  FROM Evaluation_Response__c WHERE ImInvolvedPartyAnnotations__c IN :oldToNewInvPrtyMap.keySet()
												   AND RecordType.Name = 'Annotation']){
				Evaluation_Response__c evalRespClone = evalResp.clone(false, true, false, false);
				evalRespClone.ImInvolvedPartyAnnotations__c = oldToNewInvPrtyMap.get(evalResp.ImInvolvedPartyAnnotations__c).id;
				evalRespClone.Annotation_Source__c = evalRespClone.Annotation_Source__c.replace(String.ValueOf(evalResp.ImInvolvedPartyAnnotations__c), String.ValueOf(oldToNewInvPrtyMap.get(evalResp.ImInvolvedPartyAnnotations__c).id));
				evalResponsesClone.add(evalRespClone);
		}
		insert evalResponsesClone;
	}
}
