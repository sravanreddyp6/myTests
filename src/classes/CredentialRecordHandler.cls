public with sharing class CredentialRecordHandler {
	
    private boolean m_isExecuting = false;

	private class HouseholdUpdate {
		
		public Id mentorsTmnContactId { get; set; }
		public List<TMN_Contact__c> householdsNonMentors { get; set; }

	}

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
                
        List<TMN_Contact__c> mentors = [ SELECT Id, Household_Id__c FROM TMN_Contact__c WHERE Id = :tmnContactIdsForTheseCreds AND RecordType.DeveloperName = 'Mentor' ];
        List<TMN_Contact__c> householdMembers = [ SELECT Id, Mentor__c, Household_Id__c FROM TMN_Contact__c WHERE Mentor__c = :mentors];
        
        for(TMN_Contact__c t : householdMembers) {
        	householdMemberIdsForTheseCreds.add(t.Id);
        }
        
        	// Is the TMN_Contact__r a Mentor?
        	Boolean isMentor; 
        	for(TMN_Contact__c tC : mentors) {
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
        
        
        // Get a list of all credentials for which we have to make comparisons to determine if one or more are in the file, and which is more current.  ONLY get
        // credentials for TMN_Contact__c people who are in this trigger's update context. (Starting with just Mentors, to keep it simple...)
        List<Credential_Record__c> mentorsCredsToCompare = [ SELECT Id, Credential_Profile_Name__c, Documented_Date__c, Received_Date__c FROM Credential_Record__c WHERE TMN_Contact__c = :mentors ];
        	        
        
        Set<Mentor_Tracking_Report_Record__c> reptsForTheMentors = new Set<Mentor_Tracking_Report_Record__c>([ SELECT Id, Name, TMN_Contact__c FROM Mentor_Tracking_Report_Record__c WHERE TMN_Contact__r.Id = :mentors ]);
        List<Mentor_Tracking_Report_Record__c> reptsToUpdate = new List<Mentor_Tracking_Report_Record__c>();
        
        Set<Mentor_Tracking_Report_Record__c> householdMembersRepts = new Set<Mentor_Tracking_Report_Record__c>([ SELECT Id, Name, TMN_Contact__c, TMN_Contact__r.Id FROM Mentor_Tracking_Report_Record__c WHERE TMN_Contact__r.Id = :householdMemberIdsForTheseCreds ]);
        
        for(TMN_Contact__c aMentor : mentors) {
	        	
	        	Mentor_Tracking_Report_Record__c theContactsReptRec = new Mentor_Tracking_Report_Record__c();      	
	        	Mentor_Tracking_Report_Record__c checkForExistingReptRec = new Mentor_Tracking_Report_Record__c();
	        	
	        	for(Mentor_Tracking_Report_Record__c r : reptsForTheMentors) {
	        		if(aMentor.Id==r.TMN_Contact__c) {
	        			checkForExistingReptRec = r;
	        		}
	        	}
	        	
	        	if(checkForExistingReptRec==null) {
	        		// This should NEVER happen.  The initial insert of the Mentor_Tracking_Report_Record__c record is happening in the TMN_ContactHandler.cls  Seems
	        		// to make sense to insert a record if one is NOT present, though, so I'm leaving this.  The only case I think it MIGHT execute under is if a Disregarded TMN_Contact__c
	        		// is switched to Active or such.
	        		theContactsReptRec.TMN_Contact__c = aMentor.Id;
	        		insert theContactsReptRec;	
	        	}
	        	else {
	        		theContactsReptRec = checkForExistingReptRec;
	        	}

	        for(Credential_Record__c cR : theseCredRecs) {
	        	System.debug('Check 1');
	        	System.debug('cR.TMN_Contact__r.Id: ' + cR.TMN_Contact__r.Id);
	        	System.debug('aMentorOrHouseholdMember.Id: ' + aMentor.Id);
	       		if(cR.TMN_Contact__c==aMentor.Id) {    	
		        	System.debug('Check 2');
		        	// Check to see if the credential record's TMN_Contact__c parent record belongs to a Mentor...        	
		        	if(cR.TMN_Contact__r.Id==cR.TMN_Contact__r.Household_Id__c) {
		        		// If it DOES, then we've had a NEW insert of each of the Credential_Record__c credential profiles represented by the incoming list.  A given contact should 
		        		// only ever have ONE record for any given Credential_Profile__c cred.  AFTER AN UPDATE, we DO care about the data in the records.
		
			     		if(cR.Credential_Profile_Name__c=='Health Inspection') {
			    			System.debug('Check 3');
			    			System.debug('What is theContactReptRec: ' + theContactsReptRec);
			    			
			    			// Check to see if the 'Health Inspection-Due to Move' is also in the file.
			    			for(Credential_Record__c cRCompare1 : mentorsCredsToCompare) {
			    				if(cRCompare1.Credential_Profile_Name__c=='Health Inspection-Due to Move') {
			    					// If 'Health Inspection-Due to Move' IS in the file, figure out which one is more recent.  Use the "Documented Date" to determine which is more current.
			    					// Insert the Documented Date and Documentation status based on the more recent document.
			    					if(cR.Documented_Date__c > cRCompare1.Documented_Date__c) {
			    						theContactsReptRec.Date_Most_Recent_HHSI__c = cR.Documented_Date__c;
			    						if(cR.Received_Date__c!=null) {
											theContactsReptRec.Doc_of_Home_Safety_Inspection_in_File__c = 'Yes';
										}
										else {
											theContactsReptRec.Doc_of_Home_Safety_Inspection_in_File__c = 'No';
										}
			    					}
			    					else if(cR.Documented_Date__c < cRCompare1.Documented_Date__c) {
			    						theContactsReptRec.Date_Most_Recent_HHSI__c = cRCompare1.Documented_Date__c;
			    						if(cRCompare1.Received_Date__c!=null) {
											theContactsReptRec.Doc_of_Home_Safety_Inspection_in_File__c = 'Yes';
										}
										else {
											theContactsReptRec.Doc_of_Home_Safety_Inspection_in_File__c = 'No';
										}
			    					}
			    				}
			    			}
			    		}
			     		if(cR.Credential_Profile_Name__c=='Health Inspection-Due to Move') {
			    			System.debug('Check 3A');
			    			
			    			// Check to see if the 'Health Inspection' is also in the file.
			    			for(Credential_Record__c cRCompare2 : mentorsCredsToCompare) {
			    				if(cRCompare2.Credential_Profile_Name__c=='Health Inspection') {
			    					// If 'Health Inspection' IS in the file, figure out which one is more recent.  Use the "Documented Date" to determine which is more current.
			    					// Insert the Documented Date and Documentation status based on the more recent document.
			    					if(cR.Documented_Date__c > cRCompare2.Documented_Date__c) {
			    						theContactsReptRec.Date_Most_Recent_HHSI__c = cR.Documented_Date__c;
			    						if(cR.Received_Date__c!=null) {
											theContactsReptRec.Doc_of_Home_Safety_Inspection_in_File__c = 'Yes';
										}
										else {
											theContactsReptRec.Doc_of_Home_Safety_Inspection_in_File__c = 'No';
										}
			    					}
			    					else if(cR.Documented_Date__c < cRCompare2.Documented_Date__c) {
			    						theContactsReptRec.Date_Most_Recent_HHSI__c = cRCompare2.Documented_Date__c;
			    						if(cRCompare2.Received_Date__c!=null) {
											theContactsReptRec.Doc_of_Home_Safety_Inspection_in_File__c = 'Yes';
										}
										else {
											theContactsReptRec.Doc_of_Home_Safety_Inspection_in_File__c = 'No';
										}
			    					}
			    				}
			    			}
			    		}
			    		 				
			     		if(cR.Credential_Profile_Name__c=='Fire Inspection') {
			    			System.debug('Check 4');
			    			theContactsReptRec.Date_Most_Recent_Fire_Safety__c = cR.Documented_Date__c;
							if(cR.Received_Date__c!=null) {
								theContactsReptRec.Doc_of_Fire_Safety_in_File__c = 'Yes';
							}
							else {
								theContactsReptRec.Doc_of_Fire_Safety_in_File__c = 'No';
							}
			    		}
					}
		        	// ELSE IF it's NOT a Mentor...
		        	else {
		        		System.debug('Check 5');
		        	}					
	       		}
	        }
	        					    						
			// Get the list of household members from our map.
				System.debug('Check 6');
				List<TMN_Contact__c> householdToUpdate = mentorsToHouseholdMembers.get(aMentor.Id);
				for(TMN_Contact__c householdMember : householdToUpdate) {
					System.debug('Check 8');
					for(Mentor_Tracking_Report_Record__c houseMemberReport : householdMembersRepts) {
						System.debug('Check 9');
						// HERE we update the values of all household members if the MENTOR's credential value is what we want to see on the DHR CPA report.
						if(householdMember.Id==houseMemberReport.TMN_Contact__r.Id) {
							for(Credential_Record__c cR2 : theseCredRecs) {
								if(cR2.TMN_Contact__c==householdMember.Mentor__c) {
									System.debug('Check 10');
									if(cR2.Credential_Profile_Name__c=='Health Inspection') {
										System.debug('Check 11');
										houseMemberReport.Date_Most_Recent_HHSI__c = cR2.Documented_Date__c;
										if(cR2.Received_Date__c!=null) {
											houseMemberReport.Doc_of_Home_Safety_Inspection_in_File__c = 'Yes';
										}
										else {
											houseMemberReport.Doc_of_Home_Safety_Inspection_in_File__c = 'No';
										}
									}
									if(cR2.Credential_Profile_Name__c=='Fire Inspection') {
										System.debug('Check 12');
										houseMemberReport.Date_Most_Recent_Fire_Safety__c = cR2.Documented_Date__c;
										if(cR2.Received_Date__c!=null) {
											houseMemberReport.Doc_of_Fire_Safety_in_File__c = 'Yes';
										}
										else {
											houseMemberReport.Doc_of_Fire_Safety_in_File__c = 'No';
										}
									}
								}
							}
							reptsToUpdate.add(houseMemberReport);	
						}
					}
				}
			
	        System.debug('Check 13');
	    	reptsToUpdate.add(theContactsReptRec);
		}  	
        System.debug('Check 14');
       	update reptsToUpdate;
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