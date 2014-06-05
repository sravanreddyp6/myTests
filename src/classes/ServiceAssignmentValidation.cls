public class ServiceAssignmentValidation {

    private boolean m_isExecuting = false;

    public ServiceAssignmentValidation(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Service_Assignment__c[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
 	    for(Service_Assignment__c sA : newObjects) {
        	sA.DocDueFromPerson__c = sA.Person_Being_Served__r.Owner.Id;
        }
        	
 		ServiceAssignmentValidation.checkProgressNoteEndDates(newObjects);
    }

    public void OnAfterInsert(Service_Assignment__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
        //docPop(newObjects);
    }

    public void OnBeforeUpdate(Service_Assignment__c[] oldObjects, Service_Assignment__c[] updatedObjects, Map<Id,Service_Assignment__c> newObjMap){
        // BEFORE UPDATE LOGIC
		ServiceAssignmentValidation.checkProgressNoteEndDates(updatedObjects);
    }

    public void OnAfterUpdate(Service_Assignment__c[] oldObjects, Service_Assignment__c[] updatedObjects, Map<Id,Service_Assignment__c> newObjMap){
        // AFTER UPDATE LOGIC
        
        clearUnfiledNowMissingContractOrProgramAssoc(updatedObjects);
        
        for(Service_Assignment__c o : oldObjects) {
        	for(Service_Assignment__c u : updatedObjects) {
        		if(o.Id==u.Id && (o.Start_Date__c!=u.Start_Date__c || o.End_Date__c!=u.End_Date__c || o.Projected_Treatment_End_Date__c!=u.Projected_Treatment_End_Date__c || o.Program__c!=u.Program__c || o.Service_Line__c!=u.Service_Line__c) && u.RecordType.Name!='Assessment Only'){
					if(updatedObjects.size()==1){	
						DocumentMethods.docPop(u,'updateAll');
					}
        		}
        	}  
    	}
    }

    public void OnBeforeDelete(Service_Assignment__c[] ObjectsToDelete, Map<Id,Service_Assignment__c> oldObjMap){} // ADD BEFORE DELETE LOGIC BETWEEN BRACES 

    public void OnAfterDelete(Service_Assignment__c[] deletedObjects, Map<Id,Service_Assignment__c> oldObjMap){
        // AFTER DELETE LOGIC
        deleteDocRecords(deletedObjects);  
    }

    public void OnUndelete(Service_Assignment__c[] restoredObjects){} // ADD AFTER UNDELETE LOGIC BETWEEN BRACES

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
// ------------------------------------
//
//
// END TRIGGER HANDLER TEMPLATE
//
// ---------------------------------------
// 
// START METHODS FOR WORK IN THIS HANDLER
// 
// 
// ---------------------------------------    
    	
	
	public enum Quarter { 
		ONE, 
		TWO, 
		THREE, 
		FOUR 
	}
	
	public static void checkProgressNoteEndDates(Service_Assignment__c[] servAssigns) {
		// This method essentially checks to see if a Service Assignment's end date being saved is before any end dates for Progress Notes
		// associated with the Service Assignment.
		
		List<Service_Assignment__c> theseServAssigns = new List<Service_Assignment__c>();
		theseServAssigns = servAssigns;
		
		string servAssignIdsToLimitProgressNoteQuery;
	
		
	
		// SELECT ALL PROGRESS NOTES FOR THE SERVICE ASSIGNMENT
		List<Progress_Note__c> allProgressNotes = new List<Progress_Note__c>();
		allProgressNotes = [SELECT Id, Start_Time__c, End_Time__c, Service_Assignment__c FROM Progress_Note__c WHERE Service_Assignment__c IN :theseServAssigns];
		System.Debug('What is in allProgressNotes?: ' + allProgressNotes);
		
		for(Service_Assignment__c thisSa : theseServAssigns){
			Map<Id, Progress_Note__c> mapOfAllProgressNotesThisServAssign = new Map<Id, Progress_Note__c>();
			
			for(Progress_Note__c pNs : allProgressNotes){
				if(pNs.Service_Assignment__c == thisSa.Id){
					mapOfAllProgressNotesThisServAssign.put(pNs.Id, pNs);
				}
			}
			
			System.Debug('What is in :mapOfAllProgressNotesThisServAssign ' + mapOfAllProgressNotesThisServAssign);
			
			Datetime highestProgressNoteEndTime;
			
			for(Id progressNotesToCheck : mapOfAllProgressNotesThisServAssign.keySet()){
				System.Debug('What is in progressNotesToCheck: ' + progressNotesToCheck);
				System.Debug('What is in mapOfAllProgressNotesThisServAssign.get(progressNotesToCheck).End_Time__c: ' + mapOfAllProgressNotesThisServAssign.get(progressNotesToCheck).End_Time__c);
				if(highestProgressNoteEndTime == NULL){
					System.Debug('NULL CHECK EXECUTED!');
					highestProgressNoteEndTime = date.valueOf(mapOfAllProgressNotesThisServAssign.get(progressNotesToCheck).End_Time__c);
				}
				else if(mapOfAllProgressNotesThisServAssign.get(progressNotesToCheck).End_Time__c > highestProgressNoteEndTime){
					System.Debug('DATE CHECK EXECUTED!');
					highestProgressNoteEndTime = date.valueOf(mapOfAllProgressNotesThisServAssign.get(progressNotesToCheck).End_Time__c);
				}
				System.Debug('What is in highestProgressNoteEndTime: ' + highestProgressNoteEndTime);
			}
			
			System.Debug('What is in highestProgressNoteEndTime: ' + highestProgressNoteEndTime);
			
			if(thisSa.End_Date__c == null || thisSa.CreatedDate == null){
				// DO NOTHING
			}
			else{
				Datetime servAssignEndDatetimeJustBeforeMidnight = datetime.newInstance(thisSa.End_Date__c.year(), thisSa.End_Date__c.month(), thisSa.End_Date__c.day(), 23, 59, 59);
				System.Debug('What is in servAssignEndDatetimeJustBeforeMidnight?: ' + servAssignEndDatetimeJustBeforeMidnight);
				if(servAssignEndDatetimeJustBeforeMidnight < highestProgressNoteEndTime){
					thisSa.addError('You have attempted to end a service assignment with an end date prior to the end date/time for a progress note associated with the service assignment. Please check the end date/times of the associated progress notes or the end date of the service assignment entered and adjust as needed.  The last progress note end date/time for this service assignment is currently ' + highestProgressNoteEndTime);
				}
			}
		}
	}


	public static void clearUnfiledNowMissingContractOrProgramAssoc(Service_Assignment__c[] servAssigns) {

    	Service_Assignment__c theServAssign = new Service_Assignment__c();
    
    	for(Service_Assignment__c sA : servAssigns) {
    			theServAssign = sA;
    	}

		// Get a map of the pre-existing document filing records (filed or unfiled) with ID key.
		List<ServiceAssignment_Document_JO__c> listOfPreExistingServAssignDocXrefs = new List<ServiceAssignment_Document_JO__c>();
		Map<Id,ServiceAssignment_Document_JO__c> mapOfPreExistingServAssignDocXrefs = new Map<Id,ServiceAssignment_Document_JO__c>();
		listOfPreExistingServAssignDocXrefs = [ SELECT Document__c, File_Status__c, Relative_Due_Date_Resolved__c, Fixed_Due_Date__c, Document__r.Type__c FROM ServiceAssignment_Document_JO__c WHERE Service_Assignment__c = :theServAssign.Id ];
		for(ServiceAssignment_Document_JO__c l : listOfPreExistingServAssignDocXrefs) {
			mapOfPreExistingServAssignDocXrefs.put(l.Id,l);
		}


		// Get current set of Contracts and Programs that are associated with the Service Assignment
		List<Id> contractIdsCurrentlyAssociatedWithServAssign = new List<Id>();
		String programCurrentlyAssociatedWithServAssign = theServAssign.Program__c;
		
        // Select all cross-references between Contracts and this Service Assignment.
        List<ServiceAssignment_Contract_JO__c> servAssignContractXrefs = [ SELECT Id, Name, Contract__c FROM ServiceAssignment_Contract_JO__c WHERE Service_Assignment__c = :theServAssign.Id ];

        for(ServiceAssignment_Contract_JO__c sAJC : servAssignContractXrefs) {
        	contractIdsCurrentlyAssociatedWithServAssign.add(sAJC.Contract__c);
        }
        
        // Get all documents associated with (i.e. expected for) the CONTRACTS related to this Service Assignment.
        List<Contract_Document_JO__c> contractDocXrefs = new List<Contract_Document_JO__c>();
        contractDocXrefs = [ SELECT Id, Name, Document__c FROM Contract_Document_JO__c WHERE Contract__c = :contractIdsCurrentlyAssociatedWithServAssign ];
        Set<Id> docsExpectedForTheseContracts = new Set<Id>();
        
        for(Contract_Document_JO__c cdj : contractDocXrefs) {
        	docsExpectedForTheseContracts.add(cdj.Document__c);
        }
        		
		// Get all documents associated with (i.e. expected for) the PROGRAM
		List<Program_Document_Xref__c> programDocXrefs = new List<Program_Document_Xref__c>();
		programDocXrefs = [ SELECT Id, Name, Document__c FROM Program_Document_Xref__c WHERE Program__c = :theServAssign.Program__c ];
		Set<Id> docsExpectedForThisProgram = new Set<Id>();
		
		for(Program_Document_Xref__c pdx : programDocXrefs) {
			docsExpectedForThisProgram.add(pdx.Document__c);		
		}
		

		// Loop through that map of pre-existing ServiceAssignment_Document_JO__c records, match for documents in the docsExpectedForThisProgram set.
		// If the DocID IS NOT matched, then put the sadjo record in a list to be deleted and then delete the records in the list.
		List<ServiceAssignment_Document_JO__c> listOfSadjosToDelete = new List<ServiceAssignment_Document_JO__c>();
		List<Id> sadjoIdsToDelete = new List<Id>();
		
		for(ID i : mapOfPreExistingServAssignDocXrefs.keySet()) {
			Boolean deleteTheSadjo = true;
			for(Id dForProg : docsExpectedForThisProgram) {
				if(dForProg==mapOfPreExistingServAssignDocXrefs.get(i).Document__c || mapOfPreExistingServAssignDocXrefs.get(i).File_Status__c!='Not Filed') {
					deleteTheSadjo = false;
				}
			}
			if(deleteTheSadjo==true) {
				sadjoIdsToDelete.add(i);
			}
		}

		for(Id i : sadjoIdsToDelete) {
			delete mapOfPreExistingServAssignDocXrefs.get(i);
			mapOfPreExistingServAssignDocXrefs.remove(i);
		}
		
		sadjoIdsToDelete.clear();
		
		// Loop AGAIN through the map of pre-existing ServiceAssignment_Document_JO__c records, match for documents in the docsExpectedForTheseContracts set.
		// If the DocID IS NOT matched, then put the sadjo record in a list to be deleted and then delete the records in the list.
		for(ID i : mapOfPreExistingServAssignDocXrefs.keySet()) {
			Boolean deleteTheSadjo = true;
			for(Id dForCont : docsExpectedForTheseContracts) {
				if(dForCont==mapOfPreExistingServAssignDocXrefs.get(i).Document__c || mapOfPreExistingServAssignDocXrefs.get(i).File_Status__c!='Not Filed') {
					deleteTheSadjo = false;
				}
			}
			if(deleteTheSadjo==true && mapOfPreExistingServAssignDocXrefs.get(i).Document__r.Type__c!='Fidelity Document') {
				sadjoIdsToDelete.add(i);
			}
		}

		for(Id i : sadjoIdsToDelete) {
			delete mapOfPreExistingServAssignDocXrefs.get(i);
			mapOfPreExistingServAssignDocXrefs.remove(i);
		}
				
			
	}
	
	
	public static void deleteDocRecords(Service_Assignment__c[] servAssigns) {

    	Service_Assignment__c theServAssign = new Service_Assignment__c();
    
    	for(Service_Assignment__c sA : servAssigns) {
    			theServAssign = sA;
    	}

		// Get a list of the pre-existing document filing records (filed or unfiled)
		List<ServiceAssignment_Document_JO__c> listOfPreExistingServAssignDocXrefs = new List<ServiceAssignment_Document_JO__c>();
		listOfPreExistingServAssignDocXrefs = [ SELECT Document__c, File_Status__c, Relative_Due_Date_Resolved__c, Fixed_Due_Date__c FROM ServiceAssignment_Document_JO__c WHERE Service_Assignment__c = :theServAssign.Id ];
		
		delete listOfPreExistingServAssignDocXrefs;
		
	}

}