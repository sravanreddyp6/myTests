trigger TmnProvider on TMN_Provider__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	TmnProviderTriggerHandler handler = new TmnProviderTriggerHandler(true);

	if(Trigger.isInsert && Trigger.isBefore){
		handler.onBeforeInsert(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
	} else if(Trigger.isUpdate && Trigger.isBefore){
		handler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
	}
}