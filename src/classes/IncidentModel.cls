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
}
