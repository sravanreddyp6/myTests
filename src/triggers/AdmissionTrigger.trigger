trigger AdmissionTrigger on Admission__c (after insert, after update) {
	
    AdmissionTriggeredActions handler = new AdmissionTriggeredActions();
    /* Before Insert */
    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }

}