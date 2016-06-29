/**
 * This class is marked without sharing because we're updating a task that may not be owned by the
 * user in context.
 */
public without sharing class PB_AssociatedDocTriggeredActions {
	public void OnAfterUpdate(PB_AssociatedDoc__c[] updatedObjects, Map<Id,PB_AssociatedDoc__c> oldObjMap){
		List<Id> updatedIds = new List<Id>();
		for(PB_AssociatedDoc__c doc :updatedObjects){
			if (doc.Status__c == 'Received' && oldObjMap.get(doc.id).Status__c != 'Received'){
				updatedIds.add(doc.Id);
			}
		}

		List<Task> updateTasks = [Select id, subject, WhatId, Description
		                            from Task
		                           where What.Type = 'PB_AssociatedDoc__c'
		                             And WhatId =: updatedIds  // the associated doc Ids
		                             And status != 'Completed'];

		for(Task t : updateTasks){
			t.status = 'Completed';
			t.Description = t.Description + '\r\n\r\nThis task is closed because the associated document was updated by ' + UserInfo.getName();
		}
		update updateTasks;
	}

}