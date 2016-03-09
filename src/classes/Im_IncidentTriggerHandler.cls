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
		map<Id, Im_Incident__c> incidentTasksToDel = new  Map<Id, Im_Incident__c>();
		map<Id, Im_Incident__c> incidentsToClone = new  Map<Id, Im_Incident__c>();
        for(Im_Incident__c event : updatedObjects){
			if ((event.Status__c == 'Event-Submitted') || (event.Status__c == 'Event-Disregarded')) incidentTasksToDel.put(event.id, event);				
        	if (event.Status__c == 'Event-Submitted') incidentsToClone.put(event.id, event);
    	}
    	
    	if (incidentTasksToDel.keySet().size() > 0) deleteTasksForIncidents(incidentTasksToDel);
    	if (incidentsToClone.keySet().size() > 0) cloneIncidents(incidentsToClone);
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
		
		for (Im_Incident__c incident : incidents){
			//clone(Boolean preserveId, Boolean isDeepClone, Boolean preserveReadonlyTimestamps, Boolean preserveAutonumber)
			Im_Incident__c incidentClone = incident.clone(false, true, false, false);
			incidentClone.Status__c = 'Event-Draft';
			incidentClone.ReportedEvent__c = incident.id; // the orignal incident reported
			incidentClone.OwnerId = incident.Supervisor_for_Location__r.Salesforce_User_Account__c; // we need to do this so that the task is created for this user
			insert incidentClone;
			
			list<Im_InvolvedParty__c> involvedPartiesClones = new list<Im_InvolvedParty__c>();
			for(Im_InvolvedParty__c invPrty : incident.Im_InvolvedParties__r){
				Im_InvolvedParty__c involvedParty = invPrty.clone(false, true, false, false);
				involvedParty.Im_Incident__c = incidentClone.id;
				involvedPartiesClones.add(involvedParty);
			}
			insert involvedPartiesClones;
		}
		
		//clone evalValues
		
		
	}
}