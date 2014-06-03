public with sharing class AdmissionValidation {

    private boolean m_isExecuting = false;

    public AdmissionValidation(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Admission__c[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
        	Admission__c[] theseAdms = (Admission__c[])newObjects;
			List<Id> pbsIds = new List<Id>();
			
			for(Admission__c anAdm : theseAdms){
				pbsIds.add(anAdm.Person_Being_Served__c);
			}
			System.Debug('What is in pbsIds: ' + pbsIds);
			
			string admIdsToLimitServAssignQuery;
			
			// SELECT ALL PERSONS BEING SERVED FROM THE ADMISSION SET
			List<Account> allPbs = new List<Account>();
			allPbs = [SELECT Id FROM Account];
			
			// SELECT ALL ADMISSIONS FOR THE PERSONS BEING SERVED
			List<Admission__c> allAdmissionsForPersons = new List<Admission__c>();
			allAdmissionsForPersons = [SELECT Id, Effective_Date__c, Discharged_Date__c, Person_Being_Served__c, State__c FROM Admission__c WHERE Person_Being_Served__c = :pbsIds];
			System.Debug('What is in allAdmissionsForPersons: ' + allAdmissionsForPersons);
			
			
			// SELECT ALL SERVICE ASSIGNMENTS FOR THE ADMISSIONS
			List<Service_Assignment__c> allServAssigns = new List<Service_Assignment__c>();
			allServAssigns = [SELECT Id, Start_Date__c, End_Date__c, Admission__c, Status__c FROM Service_Assignment__c WHERE Admission__c IN :theseAdms];
			System.Debug('What is in allServAssigns?: ' + allServAssigns);
						
			
        // START: PREVENT NEW ADMISSION IF OTHER ADMISSIONS FOR PERSON BEING SERVED LACK DISCHARGE DATE
        // Only prohibit the user to create an admission if a current admission does not have the "Discharged Date" complete and the 
        // admission is related to a Person Being Served that has a Mailing State of either "FL" or "NC" and a Network Offering=ARY.
        // 08/2013 - rule applies for all states and network offerings
        
        	Boolean newAdmAllowed = true;
        
	        for(Admission__c a: theseAdms){
				for(Admission__c anAdm2: allAdmissionsForPersons){
		        	if((a.Person_Being_Served__c == anAdm2.Person_Being_Served__c) && (anAdm2.Discharged_Date__c == null) ){
		        		newAdmAllowed = false;
		        		a.addError('You have attempted to create an Admission for a Person Being Served with one or more existing Admissions that lack a Discharged Date. Please check the Discharged Date value(s) of the associated Admission(s) and adjust as needed.');
		        	}   
			        else{
			        	newAdmAllowed = newAdmAllowed;
			        }	
				}
	    	}
	    	
       
       // END: PREVENT NEW ADMISSION IF OTHER ADMISSIONS FOR PERSON BEING SERVED LACK DISCHARGE DATE
        
        
        // START: FORCE SA CLOSURES BEFORE ADM DISCHARGE
        	// This code prevents saving of an admission with status of 'Discharged' if there are
			// active Service Assignments associated with the admission.
		
			for(Admission__c thisAdm : theseAdms){
			
				Map<Id, Service_Assignment__c> mapOfAllServAssignsThisAdm = new Map<Id, Service_Assignment__c>();
			
				for(Service_Assignment__c sAs : allServAssigns){
					if(sAs.Admission__c == thisAdm.Id){
						mapOfAllServAssignsThisAdm.put(sAs.Id, sAs);
					}
				}
			
				System.Debug('What is in :mapOfAllServAssignsThisAdm ' + mapOfAllServAssignsThisAdm);		
				
				Boolean weHaveAnActiveServAssignForThisAdm = false;
				
				for(Id servAssignsToCheck : mapOfAllServAssignsThisAdm.keySet()){
					System.Debug('What is in servAssignsToCheck: ' + servAssignsToCheck);
					if(mapOfAllServAssignsThisAdm.get(servAssignsToCheck).Status__c == 'Active'){
						weHaveAnActiveServAssignForThisAdm = true;
					}
				}
				
				
				if(thisAdm.Status__c == null || thisAdm.Status__c <> 'Discharged'){
					// DO NOTHING
				}
				else if(thisAdm.Status__c == 'Discharged' && weHaveAnActiveServAssignForThisAdm == true){
						thisAdm.addError('You have attempted to discharge an admission with one or more active service assignments associated. Please check the Status value(s) of the associated service assignment(s) and adjust as needed.');
				}
				
			}
		// END: FORCE SA CLOSURES BEFORE ADM DISCHARGE
		
		// START:  PREVENT SA CUTOFF
			// This method essentially checks to see if an Admission's discharge date being saved is before any end dates for Service Assignments
			// associated with the Admission.
			
			for(Admission__c thisAdm2 : theseAdms){
			
				Map<Id, Service_Assignment__c> mapOfAllServAssignsThisAdm2 = new Map<Id, Service_Assignment__c>();
			
				for(Service_Assignment__c sAs2 : allServAssigns){
					if(sAs2.Admission__c == thisAdm2.Id){
						mapOfAllServAssignsThisAdm2.put(sAs2.Id, sAs2);
					}
				}
			
				System.Debug('What is in :mapOfAllServAssignsThisAdm2 ' + mapOfAllServAssignsThisAdm2);
				
				Datetime highestServAssignEndDate;
				
				for(Id servAssignsToCheck2 : mapOfAllServAssignsThisAdm2.keySet()){
					System.Debug('What is in servAssignsToCheck2: ' + servAssignsToCheck2);
					System.Debug('What is in mapOfAllServAssignsThisAdm2.get(servAssignsToCheck2).End_Date__c: ' + mapOfAllServAssignsThisAdm2.get(servAssignsToCheck2).End_Date__c);
					if(highestServAssignEndDate == NULL){
						System.Debug('NULL CHECK EXECUTED!');
						highestServAssignEndDate = date.valueOf(mapOfAllServAssignsThisAdm2.get(servAssignsToCheck2).End_Date__c);
					}
					else if(mapOfAllServAssignsThisAdm2.get(servAssignsToCheck2).End_Date__c > highestServAssignEndDate){
						System.Debug('DATE CHECK EXECUTED!');
						highestServAssignEndDate = date.valueOf(mapOfAllServAssignsThisAdm2.get(servAssignsToCheck2).End_Date__c);
					}
					System.Debug('What is in highestServAssignEndDate: ' + highestServAssignEndDate);
				}
				
				System.Debug('What is in highestServAssignEndDate: ' + highestServAssignEndDate);
				
				if(thisAdm2.Discharged_Date__c == null){
					// DO NOTHING
				}
				else{
					if(thisAdm2.Discharged_Date__c < highestServAssignEndDate){
						thisAdm2.addError('You have attempted to discharge an admission with a discharge date prior to the end date for a service assignment associated with the admission. Please check the end dates of the associated service assignments and adjust as needed.  The last service assignment end date for this admission is currently ' + highestServAssignEndDate);
					}
				}
			}		
			
		// END: PREVENT SA CUTOFF 	
    }

    public void OnAfterInsert(Admission__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
    }

    public void OnBeforeUpdate(Admission__c[] oldObjects, Admission__c[] updatedObjects, Map<Id,Admission__c> newObjMap){
        // BEFORE UPDATE LOGIC
        	Admission__c[] theseAdms = (Admission__c[])updatedObjects;
			
			string admIdsToLimitServAssignQuery;
			
			// SELECT ALL SERVICE ASSIGNMENTS FOR THE ADMISSION
			List<Service_Assignment__c> allServAssigns = new List<Service_Assignment__c>();
			allServAssigns = [SELECT Id, Start_Date__c, End_Date__c, Admission__c, Status__c FROM Service_Assignment__c WHERE Admission__c IN :theseAdms];
			System.Debug('What is in allServAssigns?: ' + allServAssigns);
						
			
        // START: FORCE SA CLOSURES BEFORE ADM DISCHARGE
        	// This code prevents saving of an admission with status of 'Discharged' if there are
			// active Service Assignments associated with the admission.
		
			for(Admission__c thisAdm : theseAdms){
			
				Map<Id, Service_Assignment__c> mapOfAllServAssignsThisAdm = new Map<Id, Service_Assignment__c>();
			
				for(Service_Assignment__c sAs : allServAssigns){
					if(sAs.Admission__c == thisAdm.Id){
						mapOfAllServAssignsThisAdm.put(sAs.Id, sAs);
					}
				}
			
				System.Debug('What is in :mapOfAllServAssignsThisAdm ' + mapOfAllServAssignsThisAdm);		
				
				Boolean weHaveAnActiveServAssignForThisAdm = false;
				
				for(Id servAssignsToCheck : mapOfAllServAssignsThisAdm.keySet()){
					System.Debug('What is in servAssignsToCheck: ' + servAssignsToCheck);
					if(mapOfAllServAssignsThisAdm.get(servAssignsToCheck).Status__c == 'Active'){
						weHaveAnActiveServAssignForThisAdm = true;
					}
				}
				
				
				if(thisAdm.Status__c == null || thisAdm.Status__c <> 'Discharged'){
					// DO NOTHING
				}
				else if(thisAdm.Status__c == 'Discharged' && weHaveAnActiveServAssignForThisAdm == true){
						thisAdm.addError('You have attempted to discharge an admission with one or more active service assignments associated. Please check the Status value(s) of the associated service assignment(s) and adjust as needed.');
				}
				
			}
		// END: FORCE SA CLOSURES BEFORE ADM DISCHARGE
		
		// START:  PREVENT SA CUTOFF
			// This method essentially checks to see if an Admission's discharge date being saved is before any end dates for Service Assignments
			// associated with the Admission.
			
			for(Admission__c thisAdm2 : theseAdms){
			
				Map<Id, Service_Assignment__c> mapOfAllServAssignsThisAdm2 = new Map<Id, Service_Assignment__c>();
			
				for(Service_Assignment__c sAs2 : allServAssigns){
					if(sAs2.Admission__c == thisAdm2.Id){
						mapOfAllServAssignsThisAdm2.put(sAs2.Id, sAs2);
					}
				}
			
				System.Debug('What is in :mapOfAllServAssignsThisAdm2 ' + mapOfAllServAssignsThisAdm2);
				
				Datetime highestServAssignEndDate;
				
				for(Id servAssignsToCheck2 : mapOfAllServAssignsThisAdm2.keySet()){
					System.Debug('What is in servAssignsToCheck2: ' + servAssignsToCheck2);
					System.Debug('What is in mapOfAllServAssignsThisAdm2.get(servAssignsToCheck2).End_Date__c: ' + mapOfAllServAssignsThisAdm2.get(servAssignsToCheck2).End_Date__c);
					if(highestServAssignEndDate == NULL){
						System.Debug('NULL CHECK EXECUTED!');
						highestServAssignEndDate = date.valueOf(mapOfAllServAssignsThisAdm2.get(servAssignsToCheck2).End_Date__c);
					}
					else if(mapOfAllServAssignsThisAdm2.get(servAssignsToCheck2).End_Date__c > highestServAssignEndDate){
						System.Debug('DATE CHECK EXECUTED!');
						highestServAssignEndDate = date.valueOf(mapOfAllServAssignsThisAdm2.get(servAssignsToCheck2).End_Date__c);
					}
					System.Debug('What is in highestServAssignEndDate: ' + highestServAssignEndDate);
				}
				
				System.Debug('What is in highestServAssignEndDate: ' + highestServAssignEndDate);
				
				if(thisAdm2.Discharged_Date__c == null){
					// DO NOTHING
				}
				else{
					if(thisAdm2.Discharged_Date__c < highestServAssignEndDate){
						thisAdm2.addError('You have attempted to discharge an admission with a discharge date prior to the end date for a service assignment associated with the admission. Please check the end dates of the associated service assignments and adjust as needed.  The last service assignment end date for this admission is currently ' + highestServAssignEndDate);
					}
				}
			}		
			
		// END: PREVENT SA CUTOFF 	
    }

    public void OnAfterUpdate(Admission__c[] oldObjects, Admission__c[] updatedObjects, Map<Id,Admission__c> newObjMap){
        // AFTER UPDATE LOGIC
    }

    public void OnBeforeDelete(Admission__c[] ObjectsToDelete, Map<Id,Admission__c> oldObjMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Admission__c[] deletedObjects, Map<Id,Admission__c> oldObjMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Admission__c[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
}


/*
	// Version 1 by J. Gilliam, 1/29/13

	public static void checkForActiveServiceAssignments(Admission__c[] admissions) {
		// This method prevents saving of an admission with status of 'Discharged' if there are
		// active Service Assignments associated with the admission.
		
		List<Admission__c> theseAdms = new List<Admission__c>();
		theseAdms = admissions;

		string admIdsToLimitServAssignQuery;
		
	
		// SELECT ALL SERVICE ASSIGNMENTS FOR THE ADMISSION
		List<Service_Assignment__c> allServAssigns = new List<Service_Assignment__c>();
		allServAssigns = [SELECT Id, Start_Date__c, End_Date__c, Admission__c, Status__c FROM Service_Assignment__c WHERE Admission__c IN :theseAdms];
		System.Debug('What is in allServAssigns?: ' + allServAssigns);
		
		
		for(Admission__c thisAdm : theseAdms){
		
			Map<Id, Service_Assignment__c> mapOfAllServAssignsThisAdm = new Map<Id, Service_Assignment__c>();
		
			for(Service_Assignment__c sAs : allServAssigns){
				if(sAs.Admission__c == thisAdm.Id){
					mapOfAllServAssignsThisAdm.put(sAs.Id, sAs);
				}
			}
		
			System.Debug('What is in :mapOfAllServAssignsThisAdm ' + mapOfAllServAssignsThisAdm);		
			
			Boolean weHaveAnActiveServAssignForThisAdm = false;
			
			for(Id servAssignsToCheck : mapOfAllServAssignsThisAdm.keySet()){
				System.Debug('What is in servAssignsToCheck: ' + servAssignsToCheck);
				if(mapOfAllServAssignsThisAdm.get(servAssignsToCheck).Status__c == 'Active'){
					weHaveAnActiveServAssignForThisAdm = true;
				}
			}
			
			
			if(thisAdm.Status__c == null || thisAdm.Status__c <> 'Discharged'){
				// DO NOTHING
			}
			else if(thisAdm.Status__c == 'Discharged' && weHaveAnActiveServAssignForThisAdm == true){
					thisAdm.addError('You have attempted to discharge an admission with one or more active service assignments associated. Please check the Status value(s) of the associated service assignment(s) and adjust as needed.');
			}
			
		}		
	}


	
	public static void checkServiceAssignmentEndDates(Admission__c[] admissions) {
		// This method essentially checks to see if an Admission's discharge date being saved is before any end dates for Service Assignments
		// associated with the Admission.
		
		List<Admission__c> theseAdms = new List<Admission__c>();
		theseAdms = admissions;
		
		string admIdsToLimitServAssignQuery;
		
	
		// SELECT ALL SERVICE ASSIGNMENTS FOR THE ADMISSION
		List<Service_Assignment__c> allServAssigns = new List<Service_Assignment__c>();
		allServAssigns = [SELECT Id, Start_Date__c, End_Date__c, Admission__c FROM Service_Assignment__c WHERE Admission__c IN :theseAdms];
		System.Debug('What is in allServAssigns?: ' + allServAssigns);
		
		for(Admission__c thisAdm : theseAdms){
		
			Map<Id, Service_Assignment__c> mapOfAllServAssignsThisAdm = new Map<Id, Service_Assignment__c>();
		
			for(Service_Assignment__c sAs : allServAssigns){
				if(sAs.Admission__c == thisAdm.Id){
					mapOfAllServAssignsThisAdm.put(sAs.Id, sAs);
				}
			}
		
			System.Debug('What is in :mapOfAllServAssignsThisAdm ' + mapOfAllServAssignsThisAdm);
			
			Datetime highestServAssignEndDate;
			
			for(Id servAssignsToCheck : mapOfAllServAssignsThisAdm.keySet()){
				System.Debug('What is in servAssignsToCheck: ' + servAssignsToCheck);
				System.Debug('What is in mapOfAllServAssignsThisAdm.get(servAssignsToCheck).End_Date__c: ' + mapOfAllServAssignsThisAdm.get(servAssignsToCheck).End_Date__c);
				if(highestServAssignEndDate == NULL){
					System.Debug('NULL CHECK EXECUTED!');
					highestServAssignEndDate = date.valueOf(mapOfAllServAssignsThisAdm.get(servAssignsToCheck).End_Date__c);
				}
				else if(mapOfAllServAssignsThisAdm.get(servAssignsToCheck).End_Date__c > highestServAssignEndDate){
					System.Debug('DATE CHECK EXECUTED!');
					highestServAssignEndDate = date.valueOf(mapOfAllServAssignsThisAdm.get(servAssignsToCheck).End_Date__c);
				}
				System.Debug('What is in highestServAssignEndDate: ' + highestServAssignEndDate);
			}
			
			System.Debug('What is in highestServAssignEndDate: ' + highestServAssignEndDate);
			
			if(thisAdm.Discharged_Date__c == null){
				// DO NOTHING
			}
			else{
				if(thisAdm.Discharged_Date__c < highestServAssignEndDate){
					thisAdm.addError('You have attempted to discharge an admission with a discharge date prior to the end date for a service assignment associated with the admission. Please check the end dates of the associated service assignments and adjust as needed.  The last service assignment end date for this admission is currently ' + highestServAssignEndDate);
				}
			}
		}
	}
*/