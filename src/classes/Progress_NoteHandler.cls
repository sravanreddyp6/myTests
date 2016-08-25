public with sharing class Progress_NoteHandler {

    private boolean m_isExecuting = false;
	public id therapyrectypeId;
    public Progress_NoteHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
        therapyrectypeId = Schema.SObjectType.Progress_Note__c.getRecordTypeInfosByName().get('Therapy').getRecordTypeId();
    }
	
	
    public void OnBeforeInsert(Progress_Note__c[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
        //Sravan EB-527 Aug-27, 2015 12:30 PM.
        Set<id> thisServAssigns = new set<id>();
        map<id,id> otherChosenServiceCodeMap = new map<id,id>();
        
        for(Progress_note__c pn: newObjects){
        	if(pn.RecordtypeId == therapyrectypeId){ //Collect servassign info only if the recordtype is Therapy.
        		thisServAssigns.add(pn.Service_Assignment__c);
        	}
        }
        if(thisServAssigns.size() > 0){ // this will be 0 for non therapy rectypes
        	for(ServiceAssignment_ServiceCode_JO__c sjo: [SELECT Id, Service_Code__c, Service_Assignment__c FROM ServiceAssignment_ServiceCode_JO__c WHERE Service_Assignment__c IN: thisServAssigns AND Service_Code__r.Service_Code__c = 'OTHER']){
        		otherChosenServiceCodeMap.put(sjo.Service_Assignment__c, sjo.Service_Code__c);
        	}
        	
        	for(Progress_note__c p: newObjects){
	        	if(p.Type_of_Contact__c == 'Indirect'){//Not checking the record type since Indirect picklist values is exposed only for Therapy recordtype.
	        		p.Type__c = 'Indirect';
	        		if(otherChosenServiceCodeMap.containsKey(p.Service_Assignment__c)){
	        			p.Service_Code__c = otherChosenServiceCodeMap.get(p.Service_Assignment__c);
	        		}
	        		
	        	}
	        }
        	
        }
        
        
    }

    public void OnAfterInsert(Progress_Note__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC        
    }

    public void OnBeforeUpdate(Progress_Note__c[] oldObjects, Progress_Note__c[] updatedObjects, Map<Id,Progress_Note__c> newObjMap, Map<Id, Progress_Note__c> oldObjMap){
        // BEFORE UPDATE LOGIC
        
        Boolean isTherapyPNpresent = false;
        Set<Id> theseNotesServiceAssignmentIds = new Set<Id>();
        Set<Id> emps = new Set<ID>();
        for(Progress_Note__c p : updatedObjects) {
        	theseNotesServiceAssignmentIds.add(p.Service_Assignment__c);
        	emps.add( p.clinician__c);
        	if(p.RecordtypeId == therapyrectypeId){
        		isTherapyPNpresent = true;
        	}
        }
        
        List<Diagnosis__c> listOfDxs = [ SELECT Id, Service_Assignment__c, Primary_Diagnosis__c, Secondary_Diagnosis__c, Effective_Date__c FROM Diagnosis__c WHERE Service_Assignment__c = :theseNotesServiceAssignmentIds ];
        Map<ID, TMN_User__c> empMap = new Map<ID, TMN_User__c>([ select id, employee_number__c from tmn_user__c where id in :emps]);
        map<id,id> otherChosenServiceCodeMap = new map<id,id>();
        
        if(isTherapyPNpresent){//Making sure there is a therapy progress notes that is updates - issue query only when needed - Sravan
        	for(ServiceAssignment_ServiceCode_JO__c sjo: [SELECT Id, Service_Code__c, Service_Assignment__c FROM ServiceAssignment_ServiceCode_JO__c WHERE Service_Assignment__c IN: theseNotesServiceAssignmentIds AND Service_Code__r.Service_Code__c = 'OTHER']){
        		otherChosenServiceCodeMap.put(sjo.Service_Assignment__c, sjo.Service_Code__c);
        	}
        }
        for(Progress_Note__c p : updatedObjects) {
        	// EB-526 - update the credentials field with TMN User info - can't do as formula due to max # of lookups on object
        	
        	if ( p.Clinician__c != null) 
        		p.Clinician_Employee_ID__c = empMap.get( p.Clinician__c).Employee_Number__c;
        		
        	system.debug( 'Clinician: ' + p.Clinician__c + ', Employee ID:' + p.clinician_employee_ID__c);
        	// END EB-526
        	
        		
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
        	//EB-527
        	if(p.RecordtypeId == therapyrectypeId){
        		if(p.Type_of_Contact__c == 'Indirect'){
        			p.Type__c = 'Indirect';
        			if(otherChosenServiceCodeMap.containsKey(p.Service_Assignment__c)){
	        			p.Service_Code__c = otherChosenServiceCodeMap.get(p.Service_Assignment__c);
	        		}
        		}
        		
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