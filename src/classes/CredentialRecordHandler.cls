public with sharing class CredentialRecordHandler {
	
    private boolean m_isExecuting = false;

    public CredentialRecordHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Credential_Record__c[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
    }

    public void OnAfterInsert(Credential_Record__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
        List<Credential_Record__c> theseCredRecs = newObjects;
        
        for(Credential_Record__c cR : theseCredRecs) {
        	
        	Mentor_Tracking_Report_Record__c theContactsReptRec = new Mentor_Tracking_Report_Record__c();
        	
        	Mentor_Tracking_Report_Record__c checkForExistingReptRec = [ SELECT Id FROM Mentor_Tracking_Report_Record__c WHERE TMN_Contact__r.Id = :cR.TMN_Contact__c ];
        	
        	if(checkForExistingReptRec==null) {
        		theContactsReptRec.TMN_Contact__c = cR.TMN_Contact__c;
        		insert theContactsReptRec;	
        	}
        	else {
        		theContactsReptRec = checkForExistingReptRec;
        	}
        	
        	
        	// Check to see if the credential record's TMN_Contact__c parent record belongs to a Mentor...        	
        	if(cR.TMN_Contact__r.Id==cR.TMN_Contact__r.Mentor__r.Id) {
        		// If it DOES, then we've had a NEW insert of each of the Credential_Record__c credential profiles represented by the incoming list.  A given contact should 
        		// only ever have ONE record for any given Credential_Profile__c cred.  Also, the initial insertx
        	}
        	      	
        }
                
    }

    public void OnBeforeUpdate(Credential_Record__c[] oldObjects, Credential_Record__c[] updatedObjects, Map<Id,Credential_Record__c> newObjMap){
        // BEFORE UPDATE LOGIC 	
    }

    public void OnAfterUpdate(Credential_Record__c[] oldObjects, Credential_Record__c[] updatedObjects, Map<Id,Credential_Record__c> newObjMap){
        // AFTER UPDATE LOGIC
    }

    public void OnBeforeDelete(Credential_Record__c[] ObjectsToDelete, Map<Id,Credential_Record__c> oldObjMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Credential_Record__c[] deletedObjects, Map<Id,Credential_Record__c> oldObjMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Credential_Record__c[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
}