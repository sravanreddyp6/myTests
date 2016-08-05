trigger TmnProviderApplication on TMN_Provider_Application__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	TmnProviderApplicationTriggerHandler handler = new TmnProviderApplicationTriggerHandler(true);

	if (Trigger.isInsert && Trigger.isBefore) {
		handler.onBeforeInsert(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
	} else if (Trigger.isUpdate && Trigger.isBefore) {
		handler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
	} else if (Trigger.isInsert && Trigger.isAfter) {
		handler.onAfterInsert(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
	} else if (Trigger.isUpdate && Trigger.isAfter) {
		handler.onAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
	}
}