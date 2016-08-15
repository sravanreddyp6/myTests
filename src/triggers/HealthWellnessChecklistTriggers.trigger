trigger HealthWellnessChecklistTriggers on Health_Wellness_Checklist__c (after insert, after update) {
	HealthWellnessChecklistTriggeredActions handler = new HealthWellnessChecklistTriggeredActions();

	/* After Insert */
	if(Trigger.isInsert && Trigger.isAfter){
		handler.OnAfterInsert(Trigger.new);
	}
	/* After Update */
	else if(Trigger.isUpdate && Trigger.isAfter){
		handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
	}
}