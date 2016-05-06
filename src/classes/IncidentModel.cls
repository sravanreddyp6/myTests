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
}
