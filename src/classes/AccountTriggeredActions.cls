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

    public void OnBeforeUpdate(Account[] oldObjects, Account[] updatedObjects, Map<Id,Account> newObjMap, Map<Id, Account> oldObjMap){
        // BEFORE UPDATE LOGIC
        
 		for(Account x : updatedObjects ){
			
			for(Account oA : oldObjects) {
				if(x.OwnerId!=oA.OwnerId) {
					// SECURITY CHANGES:  Kick off update of any Lookup child object records so that ownership for those child records
					// is changed to the owner of the appropriate queue.  The fact that the Account record
					// moved to a new owner PROBABLY MOST OFTEN will NOT require a change to new queues for the 
					// lookup children, as we're aiming for state-wide visibility with state queues for most
					// Mentor business lines / states.  In the Mentor states where we have regional-level restrictions
					// (such as, one group home not seeing records for another), a move from one region to another
					// SHOULD kick off the queue change for the child records.  J. Gilliam, 4/10/14
					
					// SECURITY CHANGES:  Assessment__c Objective__c
					// 1. Get Assessment__c records that are children of these accounts.
					List<Assessment__c> assmtList = [ SELECT Id FROM Assessment__c WHERE AccountPerson__c = :x.Id ];
					// 2. Get the queue for the state that the owner works in.
					String queueDevName = 'ClinicalLeads_CA_San_Diego';
					Group theClinicalQueue = Database.Query('SELECT Id, DeveloperName FROM Group WHERE Type = \'Queue\' AND DeveloperName = \'' + queueDevName + '\' LIMIT 1');
					System.debug('Assessment Queue Dev Name: ' + theClinicalQueue.DeveloperName);
					// 3. Loop through the assessments, and assign their ownership to the "correct queue" that matches up with the move
					// for the PBS owner.  Is that by state of the owner?
					for(Assessment__c a : assmtList) {
						a.OwnerId = theClinicalQueue.Id;
					}
					update assmtList;
				}
			}
			
	        // check that owner is a user (not a queue)
	        if( ((String)x.OwnerId).substring(0,3) == '005' ){
	            x.Owner_Copy__c = x.OwnerId;
	        }
	        else{
	            // in case of Queue we clear out our copy field
	            x.Owner_Copy__c = null;
	        }
	        
	        // EB-143 - blank out avatar upload tag if billing id or state change
	        if ( ( x.avatar_id__pc != oldObjMap.get(x.Id).avatar_id__pc) ||( x.PersonMailingStateCode != oldObjMap.get(x.Id).PersonMailingStateCode) ) {
        		System.Debug( 'billing ids do not match');
        		x.avatar_unique_id__pc = '';
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