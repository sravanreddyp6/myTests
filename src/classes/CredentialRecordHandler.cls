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
        		// This should NEVER happen.  The initial insert of the Mentor_Tracking_Report_Record__c record is happening in the TMN_ContactHandler.cls.  Seems
        		// to make sense to insert a record if one is NOT present, though, so I'm leaving this.  The only case I think it MIGHT execute under is if a Disregarded TMN_Contact__c
        		// is switched to Active or such.
        		theContactsReptRec.TMN_Contact__c = cR.TMN_Contact__c;
        		insert theContactsReptRec;	
        	}
        	else {
        		theContactsReptRec = checkForExistingReptRec;
        	}
        	
        	
        	// Check to see if the credential record's TMN_Contact__c parent record belongs to a Mentor...        	
        	if(cR.TMN_Contact__r.Id==cR.TMN_Contact__r.Mentor__r.Id) {
        		// If it DOES, then we've had a NEW insert of each of the Credential_Record__c credential profiles represented by the incoming list.  A given contact should 
        		// only ever have ONE record for any given Credential_Profile__c cred.  Also, the initial insert shouldn't have any data we care about.  So, for now, I'm leaving the inserts
        		// alone.
        	}
        	      	
        }
                
    }

    public void OnBeforeUpdate(Credential_Record__c[] oldObjects, Credential_Record__c[] updatedObjects, Map<Id,Credential_Record__c> newObjMap){
        // BEFORE UPDATE LOGIC 	
    }

    public void OnAfterUpdate(Credential_Record__c[] oldObjects, Credential_Record__c[] updatedObjects, Map<Id,Credential_Record__c> newObjMap){
        // AFTER UPDATE LOGIC
        
        // After the update of a set of credentials, we need to look at all the changes, and update the Mentor_Tracking_Report_Record__c as needed.
        List<Credential_Record__c> theseCredRecs = updatedObjects;
        Set<Id> tmnContactIdsForTheseCreds = new Set<Id>();
        Set<Id> householdMemberIdsForTheseCreds = new Set<Id>();
        
        
        List<Credential_Record__c> aPartiallistOfCreds = new List<Credential_Record__c>();
		Map<Id,List<Credential_Record__c>> mapOfTmnContactIdsToCredIds = new Map<Id,List<Credential_Record__c>>();
		
		for(Credential_Record__c thisCred : theseCredRecs) {
			tmnContactIdsForTheseCreds.add(thisCred.TMN_Contact__c);
		}
		
		for(Id aTmnContact : tmnContactIdsForTheseCreds) {
			for(Credential_Record__c cred : theseCredRecs) {
				if(cred.TMN_Contact__r.Id==aTmnContact) {
					aPartialListOfCreds.add(cred);
				}
			}
			mapOfTmnContactIdsToCredIds.put(aTmnContact,aPartialListOfCreds);
		}
        
        
        // Map of TMN_Contact__c (Mentors) to List<TMN_Contact__c> (Household Members)
        Map<Id,List<TMN_Contact__c>> mentorsToHouseholdMembers = new Map<Id,List<TMN_Contact__c>>();
                
        List<TMN_Contact__c> tmnContacts = [ SELECT Id, Mentor__c, Household_Id__c FROM TMN_Contact__c WHERE Id = :tmnContactIdsForTheseCreds ];
        List<TMN_Contact__c> householdMembers = [ SELECT Id, Mentor__c, Household_Id__c FROM TMN_Contact__c WHERE Mentor__c = :tmnContacts];
        
        for(TMN_Contact__c t : householdMembers) {
        	householdMemberIdsForTheseCreds.add(t.Id);
        }
        
        	// Is the TMN_Contact__r a Mentor?
        	Boolean isMentor; 
        	for(TMN_Contact__c tC : tmnContacts) {
        		// If it IS a Mentor, then we need to find all the child household members.
        		List<TMN_Contact__c> thisHouseholdsMembers = new List<TMN_Contact__c>();
        		if(tC.Household_Id__c==tC.Id) {
        			isMentor=true;
        		}
        		else {
        			isMentor=false;
        		}
        		if(isMentor==true) {
        			for(TMN_Contact__c tC2 : householdMembers) {
        				System.debug('Who is TC2: ' + tC2);
        				if(tC.id==tC2.Mentor__c) {
        					thisHouseholdsMembers.add(tC2);
        				}	
        			}
        		}
        		mentorsToHouseholdMembers.put(tC.Id,thisHouseholdsMembers);
        	}
        	
        	for(Id id : mentorsToHouseholdMembers.keySet()) {
        		System.debug('Id: ' + id);
        		System.debug('mentorsToHouseholdMembers.get(id): ' + mentorsToHouseholdMembers.get(id));
        	}
        	
        	// If it IS NOT a Mentor, then we need to reference the parent Mentor TMN_Contact__c record and do work...
        	        
        
        Set<Mentor_Tracking_Report_Record__c> reptsForTheTmnContacts = new Set<Mentor_Tracking_Report_Record__c>([ SELECT Id, Name, TMN_Contact__c FROM Mentor_Tracking_Report_Record__c WHERE TMN_Contact__r.Id = :tmnContactIdsForTheseCreds ]);
        List<Mentor_Tracking_Report_Record__c> reptsToUpdate = new List<Mentor_Tracking_Report_Record__c>();
        
        Set<Mentor_Tracking_Report_Record__c> householdMembersRepts = new Set<Mentor_Tracking_Report_Record__c>([ SELECT Id, Name, TMN_Contact__c FROM Mentor_Tracking_Report_Record__c WHERE TMN_Contact__r.Id = :householdMemberIdsForTheseCreds ]);
        
        for(Credential_Record__c cR : theseCredRecs) {
        	
        	Mentor_Tracking_Report_Record__c theContactsReptRec = new Mentor_Tracking_Report_Record__c();      	
        	Mentor_Tracking_Report_Record__c checkForExistingReptRec = new Mentor_Tracking_Report_Record__c();
        	
        	for(Mentor_Tracking_Report_Record__c r : reptsForTheTmnContacts) {
        		if(cR.TMN_Contact__c==r.TMN_Contact__c) {
        			checkForExistingReptRec = r;
        		}
        	}
        	
        	if(checkForExistingReptRec==null) {
        		// This should NEVER happen.  The initial insert of the Mentor_Tracking_Report_Record__c record is happening in the TMN_ContactHandler.cls  Seems
        		// to make sense to insert a record if one is NOT present, though, so I'm leaving this.  The only case I think it MIGHT execute under is if a Disregarded TMN_Contact__c
        		// is switched to Active or such.
        		theContactsReptRec.TMN_Contact__c = cR.TMN_Contact__c;
        		insert theContactsReptRec;	
        	}
        	else {
        		theContactsReptRec = checkForExistingReptRec;
        	}

     		if(cR.Credential_Profile_Name__c=='H&S (Health and Safety Assessment)') {
    			theContactsReptRec.Date_Most_Recent_HHSI__c = cR.Received_Date__c;
    			reptsToUpdate.add(theContactsReptRec);
    		}       	
        	
        	// Check to see if the credential record's TMN_Contact__c parent record belongs to a Mentor...        	
        	if(cR.TMN_Contact__r.Id==cR.TMN_Contact__r.Mentor__r.Id) {
        		// If it DOES, then we've had a NEW insert of each of the Credential_Record__c credential profiles represented by the incoming list.  A given contact should 
        		// only ever have ONE record for any given Credential_Profile__c cred.  AFTER AN UPDATE, we DO care about the data in the records.
				
				
				// Get the list of household members from our map.
				for(Id id : mentorsToHouseholdMembers.keySet()) {
					List<TMN_Contact__c> householdToUpdate = new List<TMN_Contact__c>();
					if(cR.TMN_Contact__c==id) {
						householdToUpdate = mentorsToHouseholdMembers.get(id);
						for(TMN_Contact__c householdMember : householdToUpdate) {
							for(Mentor_Tracking_Report_Record__c houseMemberReport : householdMembersRepts) {
								if(cR.Credential_Profile_Name__c=='H&S (Health and Safety Assessment)') {
									houseMemberReport.Date_Most_Recent_HHSI__c = cR.Received_Date__c;
									reptsToUpdate.add(houseMemberReport);
								}
							}
						}
					}
				}
        	}        	
        	        	
        }
       // update reptsToUpdate;
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