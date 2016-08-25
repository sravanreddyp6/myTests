public without sharing class Im_IncidentTriggerHandler {
	private boolean m_isExecuting = false;

	public Im_IncidentTriggerHandler(boolean isExecuting){
		m_isExecuting = isExecuting;
	}

	public void OnBeforeInsert(Im_Incident__c[] oldObjects, Im_Incident__c[] updatedObjects, Map<Id, Im_Incident__c> oldObjMap, Map<Id,Im_Incident__c> newObjMap) {}

	public void OnAfterInsert(Im_Incident__c[] oldObjects, Im_Incident__c[] updatedObjects, Map<Id, Im_Incident__c> oldObjMap, Map<Id,Im_Incident__c> newObjMap){
		Im_Incident__c[] newEvents = new Im_Incident__c[]{};
		Im_Incident__c[] newQualifiers = new Im_Incident__c[]{};

		for (Im_Incident__c event: updatedObjects) {
			if (event.Status__c == 'Event-Draft') {
				newEvents.add(event);
			} else if (event.Status__c == 'Event-Qualifying') {
				newQualifiers.add(event);
			}
		}

		if (newEvents.size() > 0) {
			IncidentModel.createEventTasks(newEvents);
		}
		if (newQualifiers.size() > 0) {
			IncidentModel.createQualifyingTasks(newQualifiers);
		}
		IncidentModel.updateNames(updatedObjects, oldObjMap);
	}

	public void OnBeforeUpdate(Im_Incident__c[] oldObjects, Im_Incident__c[] updatedObjects, Map<Id, Im_Incident__c> oldObjMap, Map<Id,Im_Incident__c> newObjMap) {}

	public void OnAfterUpdate(Im_Incident__c[] oldObjects, Im_Incident__c[] updatedObjects, Map<Id, Im_Incident__c> oldObjMap, Map<Id,Im_Incident__c> newObjMap) {
		map<Id, Im_Incident__c> incidentTasksToDel = new Map<Id, Im_Incident__c>();
		map<Id, Im_Incident__c> incidentsToClone = new Map<Id, Im_Incident__c>();
		Im_Incident__c[] qualifiedIncidents = new Im_Incident__c[]{};
		Id[] incidentsToLock = new Id[]{};

		for(Im_Incident__c event : updatedObjects){
			if (event.Status__c == 'Event-Submitted' || event.Status__c == 'Event-Disregarded' || event.Status__c == 'Event-Closed') {
				incidentTasksToDel.put(event.Id, event);
				incidentsToLock.add(event.Id);
			} else if (event.Status__c == 'Incident-Draft' && oldObjMap.get(event.Id).Status__c != 'Incident-Draft') {
				incidentTasksToDel.put(event.id, event);
				qualifiedIncidents.add(event);
			}
			if (event.Status__c == 'Event-Submitted' && oldObjMap.get(event.Id).Status__c != event.Status__c) {
				incidentsToClone.put(event.id, event);
			}
		}
		if (incidentTasksToDel.keySet().size() > 0) {
			deleteTasksForIncidents(incidentTasksToDel);
		}
		if (incidentsToClone.keySet().size() > 0) {
			IncidentModel.cloneIncidents(incidentsToClone);
		}
		if (qualifiedIncidents.size() > 0) {
			IncidentModel.createIncidentFinalizationTasks(qualifiedIncidents);
		}
		if (incidentsToLock.size() > 0) {
			IncidentModel.lockIncidents(incidentsToLock);
		}
		IncidentModel.updateNames(updatedObjects, oldObjMap);
	}

	private void deleteTasksForIncidents(Map<Id,Im_Incident__c> incidentTasksToDel){
		list<Task> tasks2del = new list<Task>();
		delete [select id from Task where whatId IN : incidentTasksToDel.keySet()];
	}
}
