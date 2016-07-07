trigger TransactionQueueTrigger on Transaction_Queue__c (after insert, after update) {
	TransactionQueueTriggeredActions handler = new TransactionQueueTriggeredActions();
	if (Trigger.isUpdate) {
		handler.afterUpdate(Trigger.new);
	}
}