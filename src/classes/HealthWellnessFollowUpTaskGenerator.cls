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
			   AND Next_Expected_Annual_Physical_Date__c <= NEXT_N_DAYS:60
			   AND Next_Expected_Annual_Physical_Date__c > TODAY
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
		Map<Id, Service_Assignment__c> admissionToSAMap = new Map<Id, Service_Assignment__c>();
		Map<Id, Service_Assignment__c> checklistToSAMap = new Map<Id, Service_Assignment__c>();
		for (Admission__c admission: admissions) {
			admissionToSAMap.put(admission.Id, admission.Service_Agreements__r[0]);
		}
		for (Health_Wellness_Checklist__c checklist: scope) {
			checklistToSAMap.put(checklist.Id, admissionToSAMap.get(checklist.Admission__c));
		}
		// Find the person to assign the task to
		Map<Id, Id> checklistToUserMap = new Map<Id, Id>();
		Set<Id> aliasIds = new Set<Id>();
		for (Service_Assignment__c sa: checklistToSAMap.values()) {
			aliasIds.add(sa.Service_Location__r.Alias_Lookup__c);
		}
		TMN_User__c[] users = [
			SELECT Id, Alias__c
			  FROM TMN_User__c
			 WHERE Alias__c IN :aliasIds
			   AND Job_Title__c = 'Program Director'
		];
		Map<Id, Id> aliasToUserMap = new Map<Id, Id>();
		for (TMN_User__c user: users) {
			aliasToUserMap.put(user.Alias__c, user.Id);
		}
		for (Id checklistId: checklistToSAMap.keySet()) {
			Id aliasForChecklist = checklistToSAMap.get(checklistId).Service_Location__r.Alias_Lookup__c;
			if (aliasToUserMap.containsKey(aliasForChecklist)) {
				checklistToUserMap.put(checklistId, aliasToUserMap.get(aliasForChecklist));
			} else {
				checklistToUserMap.put(checklistId, checklistMap.get(checklistId).OwnerId);
			}
		}

		// Creating the tasks
		Task[] toInsert = new Task[]{};
		for (Task existingTask: [SELECT Id, WhatId FROM Task WHERE WhatId IN :checklistMap.keySet()]) {
			checklistMap.remove(existingTask.WhatId);
		}
		for (Id checklistId: checklistMap.keySet()) {
			toInsert.add(
				new Task(
					WhoId = checklistMap.get(checklistId).Admission__r.Person_Being_Served__c,
					Subject = 'Schedule Annual Physical',
					WhatId = checklistId,
					ActivityDate = checklistMap.get(checklistId).Next_Expected_Annual_Physical_Date__c,
					OwnerId = checklistToUserMap.get(checklistId),
					Description = 'It may be time to schedule an annual physical with a health care provider for this Person Being Served',
					Status = 'Not Started',
					Priority = 'Normal'
				)
			);
		}
		insert toInsert;
	}

	global void finish(Database.BatchableContext BC) {}
}