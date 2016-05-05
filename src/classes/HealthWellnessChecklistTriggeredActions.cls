public with sharing class HealthWellnessChecklistTriggeredActions {
	public void onAfterInsert(Health_Wellness_Checklist__c[] newObjects) {
		Set<Id> newIds = new Set<Id>();
		for (Health_Wellness_Checklist__c checklist: newObjects) {
			newIds.add(checklist.Id);
		}
		updateAdmissions(newIds);
	}

	public void onAfterUpdate(Health_Wellness_Checklist__c[] oldObjects, Health_Wellness_Checklist__c[] newObjects, Map<Id, Health_Wellness_Checklist__c> oldMap) {
		Set<Id> updatedIds = new Set<Id>();
		for (Health_Wellness_Checklist__c checklist: newObjects) {
			updatedIds.add(checklist.Id);
		}
		updateAdmissions(updatedIds);
	}
	public static void updateAdmissions(Set<Id> checklistIds) {
		// Update the admission field for reporting purpose
		Health_Wellness_Checklist__c[] checklists = [
			SELECT Id, Admission__c, Status__c
			  FROM Health_Wellness_Checklist__c
			 WHERE Id IN :checklistIds
		];
		Set<Id> admissionIds = new Set<Id>();
		for (Health_Wellness_Checklist__c checklist: checklists) {
			admissionIds.add(checklist.Admission__c);
		}
		Admission__c[] admissions = [
			SELECT Id, Status__c, (SELECT Id FROM Health_Wellness_Checklists__r WHERE Status__c = 'Inactive Draft')
			  FROM Admission__c
			 WHERE Id IN :admissionIds
		];
		List<Admission__c> admissionsToUpdate = new List<Admission__c>();
		for (Admission__c admission: admissions) {
			Boolean hasInactiveDraftChecklist = false;
			if (admission.Health_Wellness_Checklists__r.size() > 0) {
				hasInactiveDraftChecklist = true;
			}
			admission.Has_Inactive_Draft_Checklist__c = hasInactiveDraftChecklist;
		}
		System.debug(admissions);
		update admissions;
	}
}