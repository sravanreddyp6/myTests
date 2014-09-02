public with sharing class Progress_NoteHandler {

    private boolean m_isExecuting = false;

    public Progress_NoteHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Progress_Note__c[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
    }

    public void OnAfterInsert(Progress_Note__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC        
    }

    public void OnBeforeUpdate(Progress_Note__c[] oldObjects, Progress_Note__c[] updatedObjects, Map<Id,Progress_Note__c> newObjMap, Map<Id, Progress_Note__c> oldObjMap){
        // BEFORE UPDATE LOGIC
        Set<Id> theseNotesServiceAssignmentIds = new Set<Id>();
        for(Progress_Note__c p : updatedObjects) {
        	theseNotesServiceAssignmentIds.add(p.Service_Assignment__c);
        }
        
        List<Diagnosis__c> listOfDxs = [ SELECT Id, Service_Assignment__c, Primary_Diagnosis__c, Secondary_Diagnosis__c, Effective_Date__c FROM Diagnosis__c WHERE Service_Assignment__c = :theseNotesServiceAssignmentIds ];
        
        for(Progress_Note__c p : updatedObjects) {
        	System.debug('START: PROGRESS NOTE HANDLER LOOP FOR UPDATED DIAGNOSES; Progress_Note__c loop for updatedObjects');
        	Diagnosis__c mostRecentDx = new Diagnosis__c();
        	for(Diagnosis__c dx : listOfDxs) {
        		System.debug('START: PROGRESS NOTE HANDLER LOOP FOR UPDATED DIAGNOSES; Diagnosis__c loop for listOfDxs');
        		System.debug('dx at start of loop: ' + dx);
        		if(p.Service_Assignment__c==dx.Service_Assignment__c) {
        			if(dx.Effective_Date__c > mostRecentDx.Effective_Date__c  || mostRecentDx.Effective_Date__c==null) {
        				mostRecentDx = dx;
        				System.debug('mostRecentDx CHANGED!' + mostRecentDx);
        			}
        			else {
        				System.debug('mostRecentDx STAYS THE SAME!' + mostRecentDx);
        			}
        		}
        	}
        	if(p.Primary_Diagnosis__c==null) {
        		p.Primary_Diagnosis__c = mostRecentDx.Primary_Diagnosis__c;
        		System.debug('mostRecentDx.Primary_Diagnosis__c: ' + mostRecentDx.Primary_Diagnosis__c);
        	}
        	if(p.Secondary_Diagnosis__c==null) {
        		p.Secondary_Diagnosis__c = mostRecentDx.Secondary_Diagnosis__c;
        		System.debug('mostRecentDx.Secondary_Diagnosis__c: ' + mostRecentDx.Secondary_Diagnosis__c);
        	}
        }	
    }

    public void OnAfterUpdate(Progress_Note__c[] oldObjects, Progress_Note__c[] updatedObjects, Map<Id,Progress_Note__c> newObjMap){
        // AFTER UPDATE LOGIC        
    }

    public void OnBeforeDelete(Progress_Note__c[] ObjectsToDelete, Map<Id,Progress_Note__c> oldObjMap){
        // BEFORE DELETE LOGIC       
    }

    public void OnAfterDelete(Progress_Note__c[] deletedObjects, Map<Id,Progress_Note__c> oldObjMap){
        // AFTER DELETE LOGIC       
    }

    public void OnUndelete(Progress_Note__c[] restoredObjects){
        // AFTER UNDELETE LOGIC        
    }

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
}