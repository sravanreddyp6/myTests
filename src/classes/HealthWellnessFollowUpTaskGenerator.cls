global with sharing class HealthWellnessFollowUpTaskGenerator implements Schedulable, Database.Batchable<sObject> {
	global void execute(SchedulableContext sc) {
		ID batchprocessid = Database.executeBatch(new HealthWellnessFollowUpTaskGenerator());
	}
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
			SELECT Id, Admission__r.Person_Being_Served__r.Name, Admission__r.Person_Being_Served__c,
			       Next_Expected_Annual_Physical_Date__c, OwnerId, Admission__c
			  FROM Health_Wellness_Checklist__c
			 WHERE Admission__r.Status__c = 'Active'
			   AND Status__c = 'Active Final'
			   AND Next_Expected_Annual_Physical_Date__c = NEXT_N_DAYS:60
			   AND Next_EXpected_Annual_Physical_Date__c > TODAY
		]);
	}

	global void execute(Database.BatchableContext BC, List<Health_Wellness_Checklist__c> scope) {
		System.debug(scope);
		Map<Id, Health_Wellness_Checklist__c> checklistMap = new Map<Id, Health_Wellness_Checklist__c>(scope);

		// Figure out the Residential SAs associated with the checklists
		Set<Id> admissionIds = new Set<Id>();
		for (Health_Wellness_Checklist__c checklist: scope) {
			admissionIds.add(checklist.Admission__c);
		}
		Admission__c[] admissions = [
			SELECT Id,
			       (SELECT Id, Service_Location__r.Alias_Lookup__c From Service_Agreements__r WHERE Service_Location__r.Tmn_Scope__c = 'Residential' AND Status__c = 'Active')
			  FROM Admission__c
			 WHERE Id IN :admissionIds
		];

		// Creating the tasks
		Task[] toInsert = new Task[]{};
		for (Task existingTask: [SELECT Id, WhatId FROM Task WHERE WhatId IN :checklistMap.keySet()]) {
			checklistMap.remove(existingTask.WhatId);
		}
		Id recordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('UserTask').RecordTypeId;
		for (Id checklistId: checklistMap.keySet()) {
			toInsert.add(
				new Task(
					WhoId = checklistMap.get(checklistId).Admission__r.Person_Being_Served__c,
					Subject = 'Schedule Annual Physical',
					WhatId = checklistId,
					ActivityDate = checklistMap.get(checklistId).Next_Expected_Annual_Physical_Date__c,
					OwnerId = checklistMap.get(checklistId).ownerid,
					Description = 'It may be time to schedule an annual physical with a health care provider for this Person Being Served',
					Status = 'Not Started',
					Priority = 'Normal',
					RecordTypeId = recordTypeId
				)
			);
		}
		insert toInsert;
	}

	global void finish(Database.BatchableContext BC) {}
}