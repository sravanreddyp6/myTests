public with sharing class TaskTriggerHandler {
	private boolean m_isExecuting = false;

	public TaskTriggerHandler(boolean isExecuting){
		m_isExecuting = isExecuting;
	}

	public void OnBeforeInsert(Task[] newObjects){
		// EXECUTE BEFORE INSERT LOGIC

	}

	public void OnAfterInsert(Task[] newObjects){
		// EXECUTE AFTER INSERT LOGIC

	}

	public void OnBeforeUpdate(Task[] oldObjects, Task[] updatedObjects, Map<Id,Task> newObjMap, Map<Id, Task> oldObjMap){
		// BEFORE UPDATE LOGIC
		set<id> evalIds = new set<id>(); //get all the WhatIds that are related to Evaluation__c object
		Schema.DescribeSObjectResult objectId = Evaluation__c.sObjectType.getDescribe();
		String keyPrefix = objectId.getKeyPrefix();
		system.debug('prefix'+keyPrefix);

		List<Id> updatedDocIds = new List<Id>();
		List<Id> taskIds = new List<Id>();

		for(Task t: updatedObjects){
			if (t.WhatId == null) {
				continue;
			}
			//Include those tasks that have status changed and WhatId as Evaluation__c.
			if(string.ValueOf(t.WhatId).startswith(keyPrefix) && t.status == 'Completed' && oldObjMap.get(t.id).status != 'Completed'){
				evalIds.add(t.WhatId);
			}
			else if (t.WhatId.getSObjectType().getDescribe().getName() == 'PB_AssociatedDoc__c' && t.status == 'Completed' && oldObjMap.get(t.id).status != 'Completed' ){
				updatedDocIds.add(t.WhatId);
				taskIds.add(t.Id);
			}
		}

		Set<id> filteredIds = new set<id>(); //Filter out the final or Disregard shift Assessments from the evalIds list that is obtained first.
		for(Evaluation__c eval : [SELECT Id, Status__c FROM Evaluation__c WHERE Id IN:evalIds AND Status__c = 'Draft' AND Recordtype.Name = 'CMShiftAssessment']) {
			filteredIds.add(eval.Id);
		}

		for(Task t: updatedObjects){
			if(filteredIds.contains(t.WhatId)){
				t.addError('This task cannot be upated as the Associated Nurses Shift Documentation is not finalized or Disregarded');
			}
		}

		// the update was made to the one of the associated Doc
		if (updatedDocIds.size() > 0){
			List<PB_AssociatedDoc__c> assocDocs = [
				SELECT Id, Status__c
				  FROM PB_AssociatedDoc__c
				 WHERE Status__c != 'Received'
				   AND Id = :updatedDocIds
			];

			// at least one associated doc with the status of not Received.
			if (assocDocs.size() > 0){
				for (Id taskId : taskIds){
					newObjMap.get(taskId).addError('Task can not be completed until the associated document status is updated to Received.');
					break;
				}
			}
		}

	}

	public void OnAfterUpdate(Task[] oldObjects, Task[] updatedObjects, Map<Id,Task> newObjMap){
		// AFTER UPDATE LOGIC
	}

	public void OnBeforeDelete(Task[] ObjectsToDelete, Map<Id,Task> oldObjMap){
		// BEFORE DELETE LOGIC

	}

	public void OnAfterDelete(Task[] deletedObjects, Map<Id,Task> oldObjMap){
		// AFTER DELETE LOGIC

	}

	public void OnUndelete(Task[] restoredObjects){
		// AFTER UNDELETE LOGIC

	}

	public boolean IsTriggerContext{
		get{ return m_isExecuting;}
	}

}