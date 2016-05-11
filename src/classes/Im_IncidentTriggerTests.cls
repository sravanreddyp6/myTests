@isTest
public with sharing class Im_IncidentTriggerTests {
	public static testmethod void createTasks() {
		Im_incident__c event;
		Im_Incident__c incident;
		Task[] eventTasks;
		Task[] incidentTasks;

		Service_Location__c sl = TestUtils.createServiceLocation();
		Id supervisorId = TestUtils.createTmnUser().Id;

		event = new Im_Incident__c(
			Status__c = 'Event-Draft',
			Service_location__c = sl.Id,
			Supervisor__c = supervisorId,
			Supervisor_for_Location__C = supervisorId
		);
		insert event;
		eventTasks = [SELECT Id, OwnerId FROM Task WHERE WhatId = :event.Id];

		System.assertEquals(
			1,
			eventTasks.size(),
			'There should be 1 Task for the event'
		);
		event = [ SELECT Id, OwnerId FROM Im_Incident__c WHERE Id=:event.Id ];
		System.assertEquals(
			event.OwnerId,
			eventTasks[0].OwnerId,
			'The event task should be assigned to the correct person'
		);

		//Submit the event
		event.Status__c = 'Event-Submitted';
		update event;
		eventTasks = [SELECT Id, OwnerId FROM Task WHERE WhatId = :event.Id];
		System.assertEquals(
			0,
			eventTasks.size(),
			'The event task should be deleted after qualifier is created'
		);

		incident = [ SELECT Id FROM Im_Incident__c WHERE ReportedEvent__c = :event.Id ];
		incidentTasks = [SELECT Id, OwnerId FROM Task WHERE WhatId = :incident.Id];
		System.assertEquals(
			1,
			incidentTasks.size(),
			'There should be 1 Task for the qualifier'
		);
		incident = [ SELECT Id, OwnerId FROM Im_Incident__c WHERE Id=:incident.Id ];
		System.assertEquals(
			incident.OwnerId,
			incidentTasks[0].OwnerId,
			'The qualifier task should be assigned to the correct person'
		);
		incident.Status__c = 'Incident-Draft';
		update incident;
		incidentTasks = [SELECT Id, OwnerId FROM Task WHERE WhatId = :incident.Id];
		System.assertEquals(
			1,
			incidentTasks.size(),
			'There should be only 1 Task for the Incident'
		);
	}
}
