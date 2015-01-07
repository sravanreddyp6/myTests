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
        for(Task t: updatedObjects){
        	if(string.ValueOf(t.WhatId).startswith(keyPrefix)){
        		evalIds.add(t.WhatId);
        	}
        }
        
        Set<id> filteredIds = new set<id>();
        for(Evaluation__c eval : [SELECT Id, Status__c FROM Evaluation__c WHERE Id IN:evalIds AND Status__c = 'Draft']) {
        	filteredIds.add(eval.Id);
        }
        
        for(Task t: updatedObjects){
        	if(filteredIds.contains(t.WhatId) && oldObjMap.get(t.id).Status != 'Completed' && t.Status == 'Completed'){
        		t.addError('This task cannot be upated as the Associated Shift Assessment is not finalized or Disregarded');
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