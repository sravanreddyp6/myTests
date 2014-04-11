public with sharing class AssessmentHandler {
    private boolean m_isExecuting = false;

    public AssessmentHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Assessment__c[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
        
        String clinicalLeadQueueDevName;
        
        Map<Id,String> acctIdToClinicalLeadQueueName = new Map<Id,String>();
        
        
        List<Id> acctIds = new List<Id>();
        for(Assessment__c assmt : newObjects) {
        	acctIds.add(assmt.AccountPerson__c);
        }
		
        
        List<Account> pbsList = [ SELECT Id, PersonMailingState FROM Account WHERE Id = :acctIds ];
        for(Assessment__c assmt : newObjects) {
        	for(Account a : pbsList) {
        		if(assmt.AccountPerson__c==a.Id) {
        			// Get the right queue to put the Assessment in.
        			// What state is the user from?  What state is the client being inserted into?
        			if(a.PersonMailingState=='Arizona') {
        				acctIdToClinicalLeadQueueName.put(a.Id,'ClinicalLeads_AZ');
        			}
        			else if(a.PersonMailingState=='California') {
        				acctIdToClinicalLeadQueueName.put(a.Id,'ClinicalLeads_CA_San_Diego');
        			}
        			else {
        				acctIdToClinicalLeadQueueName.put(a.Id,'ClinicalLeads_AZ');
        			}
        		}
        	}
        }
        
        
        for(Assessment__c assmt : newObjects) {
        	for(Id i : acctIdToClinicalLeadQueueName.keySet()) {
        		if(i==assmt.AccountID__c) {
        			Group theClinicalQueue = Database.Query('SELECT Id, DeveloperName FROM Group WHERE Type = \'Queue\' AND DeveloperName = \'' + acctIdToClinicalLeadQueueName.get(i) + '\' LIMIT 1');
        			assmt.OwnerId = theClinicalQueue.Id;
        		}
        	}
        } 
        
    }

    public void OnAfterInsert(Assessment__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC 
    }

    public void OnBeforeUpdate(Assessment__c[] oldObjects, Assessment__c[] updatedObjects, Map<Id,Assessment__c> newObjMap, Map<Id, Assessment__c> oldObjMap){
        // BEFORE UPDATE LOGIC	
    }

    public void OnAfterUpdate(Assessment__c[] oldObjects, Assessment__c[] updatedObjects, Map<Id,Assessment__c> newObjMap){
        // AFTER UPDATE LOGIC
    }

    public void OnBeforeDelete(Assessment__c[] ObjectsToDelete, Map<Id,Assessment__c> oldObjMap){
        // BEFORE DELETE LOGIC        
    }

    public void OnAfterDelete(Assessment__c[] deletedObjects, Map<Id,Assessment__c> oldObjMap){
        // AFTER DELETE LOGIC     
    }

    public void OnUndelete(Assessment__c[] restoredObjects){
        // AFTER UNDELETE LOGIC   
    }

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
}