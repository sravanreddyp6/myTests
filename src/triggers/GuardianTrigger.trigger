trigger GuardianTrigger on Related_Party__c (before delete, before update, after insert) {
	GuardianTriggeredActions handler = new GuardianTriggeredActions();
	if (Trigger.isDelete) {
		handler.beforeDelete(Trigger.old, Trigger.oldMap);
	} else if (Trigger.isUpdate) {
		handler.beforeModify(Trigger.oldMap, Trigger.newMap);
	} else if (Trigger.isInsert) {
		handler.afterInsert(Trigger.new);
	}
}