public with sharing class AccountTriggeredActions {
    private boolean m_isExecuting = false;

    public AccountTriggeredActions(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Account[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
            
        Account[] theseAccts = (Account[])newObjects;
        
        // handle arbitrary number of opps
	    for(Account x : theseAccts){
	
	        // check that owner is a user (not a queue)
	        if( ((String)x.OwnerId).substring(0,3) == '005' ){
	            x.Owner_Copy__c = x.OwnerId;
	        }
	        else{
	            // in case of Queue we clear out our copy field
	            x.Owner_Copy__c = null;
	        }
	    }	
    }

    public void OnAfterInsert(Account[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
        
    }

    public void OnBeforeUpdate(Account[] oldObjects, Account[] updatedObjects, Map<Id,Account> newObjMap){
        // BEFORE UPDATE LOGIC
        
        Account[] theseAccts = (Account[])updatedObjects;
        
 		for(Account x : theseAccts){
	
	        // check that owner is a user (not a queue)
	        if( ((String)x.OwnerId).substring(0,3) == '005' ){
	            x.Owner_Copy__c = x.OwnerId;
	        }
	        else{
	            // in case of Queue we clear out our copy field
	            x.Owner_Copy__c = null;
	        }
	    }	
    }

    public void OnAfterUpdate(Account[] oldObjects, Account[] updatedObjects, Map<Id,Account> newObjMap){
        // AFTER UPDATE LOGIC
    }

    public void OnBeforeDelete(Account[] ObjectsToDelete, Map<Id,Account> oldObjMap){
        // BEFORE DELETE LOGIC
        
    }

    public void OnAfterDelete(Account[] deletedObjects, Map<Id,Account> oldObjMap){
        // AFTER DELETE LOGIC
        
    }

    public void OnUndelete(Account[] restoredObjects){
        // AFTER UNDELETE LOGIC
        
    }

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
}