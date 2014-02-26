public with sharing class MentorTrackingReportRecordHandler {
	
    private boolean m_isExecuting = false;

    public MentorTrackingReportRecordHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Mentor_Tracking_Report_Record__c[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
    }

    public void OnAfterInsert(Mentor_Tracking_Report_Record__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC     
    }

    public void OnBeforeUpdate(Mentor_Tracking_Report_Record__c[] oldObjects, Mentor_Tracking_Report_Record__c[] updatedObjects, Map<Id,Mentor_Tracking_Report_Record__c> newObjMap){
        // BEFORE UPDATE LOGIC 	
      
        // Get a list of the TMN_Contact__c records whose Mentor_Tracking_Report_Record__c records were updated in this trigger context. 
        List<Id> theTmnContactsIds = new List<Id>();
        List<Mentor_Tracking_Report_Record__c> tmnContactIdsWithUpdatedReports = [ SELECT TMN_Contact__c FROM Mentor_Tracking_Report_Record__c WHERE Id = :updatedObjects];
        
        for(Mentor_Tracking_Report_Record__c t : tmnContactIdsWithUpdatedReports) {
        	theTmnContactsIds.add(t.TMN_Contact__c);
        }
        
        
        TMN_Contact__c theTmnContact = new TMN_Contact__c();
        List<TMN_Contact__c> theTmnContacts = [ SELECT Id FROM TMN_Contact__c WHERE Id = :theTmnContactsIds ];
               
        for(Mentor_Tracking_Report_Record__c m : updatedObjects) {
 			for(TMN_Contact__c t : theTmnContacts) {
		    	if(m.TMN_Contact__c==t.Id && m.Skip_Trigger__c==false) {
		        	m.Status__c = 'Update';
		    	}
 			}
 			m.Skip_Trigger__c=false;
        }
        
    }

    public void OnAfterUpdate(Mentor_Tracking_Report_Record__c[] oldObjects, Mentor_Tracking_Report_Record__c[] updatedObjects, Map<Id,Mentor_Tracking_Report_Record__c> newObjMap){
        // AFTER UPDATE LOGIC
    }

    public void OnBeforeDelete(Mentor_Tracking_Report_Record__c[] ObjectsToDelete, Map<Id,Mentor_Tracking_Report_Record__c> oldObjMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Mentor_Tracking_Report_Record__c[] deletedObjects, Map<Id,Mentor_Tracking_Report_Record__c> oldObjMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Mentor_Tracking_Report_Record__c[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

}