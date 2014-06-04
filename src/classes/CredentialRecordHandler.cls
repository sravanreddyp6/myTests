//////////////////////////////////////////////////
// Originally Developed by: Josh Gilliam		//
// Date:  February 2014							//	
// Ticket(s):  CMMT-7 (Mentor Tracking Project) //
//////////////////////////////////////////////////
public with sharing class CredentialRecordHandler {
	
    private boolean m_isExecuting = false;
	private Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

	private class DhrUpdate2 {
		
		Credential_Record__c dhrUpdateCred { get; set; }
		string dhrFieldForUpdate { get; set; }
		string credRecSourceField { get; set; }
		string credRecDateField { get; set; }

		TMN_Contact__c dhrFocusContact { get; set; }
		Id mentorsTmnContactId { get; set; }
		TMN_Contact__c dhrUpdateMentor { get; set; }
		List<TMN_Contact__c> householdsNonMentors { get; set; }

		public DhrUpdate2(Boolean updateOrNot, Credential_Record__c aCred, TMN_Contact__c thisPerson, TMN_Contact__c aMentor, List<TMN_Contact__c> household, Mentor_Tracking_Metadata__c m) {
			dhrUpdateCred = aCred;
			dhrFieldForUpdate = m.Field_to_Update__c;
			credRecSourceField = m.Credential_Record_Source_Field__c;
			credRecDateField = m.Credential_Record_Date_Field__c;

			dhrFocusContact = thisPerson;
			dhrUpdateMentor = aMentor;
			householdsNonMentors = household;
		}
	
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
        
        List<Id> m = new List<Id>();
        
        for(Credential_Record__c c : theseCredRecs) {
        	m.add(c.TMN_Contact__c);
        }
        
        List<Mentor_Tracking_Report_Record__c> checkForExistingReptRecs = [ SELECT Id FROM Mentor_Tracking_Report_Record__c WHERE TMN_Contact__r.Id = :m ];
        
        for(Credential_Record__c cR : theseCredRecs) {
        	
        	Mentor_Tracking_Report_Record__c theContactsReptRec = new Mentor_Tracking_Report_Record__c();
        	
        	Mentor_Tracking_Report_Record__c checkForExistingReptRec = new Mentor_Tracking_Report_Record__c();
        	
        	for(Mentor_Tracking_Report_Record__c mTrr : checkForExistingReptRecs) {
        		if(mTrr.Id==cR.TMN_Contact__r.Id) {
        			checkForExistingReptRec = mTrr;
        		}
        	}
        	
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
        
        List<Mentor_Tracking_Metadata__c> metaDataRecs = [ SELECT Credential_Profile__c, Credential_Record_Date_Field__c, 
        													Credential_Record_Source_Field__c, Field_to_Update__c,
        													Report__c, Similar_Credentials__c, Supercedes__c, Superceded_By__c, 
        													Parallel_Credentials__c, Parallel_Credentials_Operator__c, Parallel_Credentials_Type__c
        													 FROM Mentor_Tracking_Metadata__c ];
        
        
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
                
        List<TMN_Contact__c> mentors = [ SELECT Id, Household_Id__c, Age__c FROM TMN_Contact__c WHERE Id = :tmnContactIdsForTheseCreds AND RecordType.DeveloperName = 'Mentor' ];
        List<TMN_Contact__c> nonMentors = [ SELECT Id, Household_Id__c, Age__c FROM TMN_Contact__c WHERE Id = :tmnContactIdsForTheseCreds AND RecordType.DeveloperName != 'Mentor' ];
        List<TMN_Contact__c> householdMembers = [ SELECT Id, Mentor__c, Household_Id__c, Age__c FROM TMN_Contact__c WHERE Mentor__c = :mentors];
        
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
        List<Credential_Record__c> mentorsCredsToCompare = [ SELECT Id, Credential_Profile__c, Credential_Profile_Name__c, Documented_Date__c, Received_Date__c, Requested_Date__c, CreatedDate,
        														Outcome_of_Clearance__c, Federal_Conviction__c, Type_of_Conviction_Federal__c, State_Conviction__c, Conviction_Past_5_Years__c,
        														Similar_Credentials__c, DHR_Scope__c,
        														DHR_Documented_Field__c, DHR_Received_Field__c, In_File__c
        														FROM Credential_Record__c WHERE TMN_Contact__c = :mentors ];
        List<Credential_Record__c> nonMentorsCredsToCompare = [ SELECT Id, Credential_Profile__c, Credential_Profile_Name__c, Documented_Date__c, Received_Date__c, Requested_Date__c, CreatedDate, 
        														Outcome_of_Clearance__c, Federal_Conviction__c, Type_of_Conviction_Federal__c, State_Conviction__c, Conviction_Past_5_Years__c,
        														Similar_Credentials__c, DHR_Scope__c,
        														DHR_Documented_Field__c, DHR_Received_Field__c, In_File__c
        														FROM Credential_Record__c WHERE TMN_Contact__c = :nonMentors ];
        	        
        
        Set<Mentor_Tracking_Report_Record__c> reptsForTheMentors = new Set<Mentor_Tracking_Report_Record__c>([ SELECT Id, Name, TMN_Contact__c FROM Mentor_Tracking_Report_Record__c WHERE TMN_Contact__r.Id = :mentors ]);
        Set<Mentor_Tracking_Report_Record__c> reptsForTheNonMentors = new Set<Mentor_Tracking_Report_Record__c>([ SELECT Id, Name, TMN_Contact__c FROM Mentor_Tracking_Report_Record__c WHERE TMN_Contact__r.Id = :nonMentors ]);
        List<Mentor_Tracking_Report_Record__c> reptsToUpdate = new List<Mentor_Tracking_Report_Record__c>();
        List<Mentor_Tracking_Report_Record__c> reptsToUpdateNonMentor = new List<Mentor_Tracking_Report_Record__c>();
        
        Set<Mentor_Tracking_Report_Record__c> householdMembersRepts = new Set<Mentor_Tracking_Report_Record__c>([ SELECT Id, Name, TMN_Contact__c, TMN_Contact__r.Id FROM Mentor_Tracking_Report_Record__c WHERE TMN_Contact__r.Id = :householdMemberIdsForTheseCreds ]);
        
        List<DhrUpdate2> theseUpdates = new List<DhrUpdate2>();      
        
        for(TMN_Contact__c aMentor : mentors) {
	        	
	        	Mentor_Tracking_Report_Record__c theContactsReptRec = new Mentor_Tracking_Report_Record__c();      	
	        	Mentor_Tracking_Report_Record__c checkForExistingReptRec = new Mentor_Tracking_Report_Record__c();
	        	
	        	for(Mentor_Tracking_Report_Record__c r : reptsForTheMentors) {
	        		if(aMentor.Id==r.TMN_Contact__c) {
	        			checkForExistingReptRec = r;
	        		}
	        	}
	        	
	        	
	        	// WORK TO CREATE THE REPORT RECORD FOR THIS MENTOR.  It stays in context until the aMentor for loop iterates.
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

			List<TMN_Contact__c> householdToUpdate = mentorsToHouseholdMembers.get(aMentor.Id);


	        for(Credential_Record__c cR : theseCredRecs) {
	        	if(cR.DHR_Scope__c!='N/A' && cR.DHR_Scope__c!=null) {
		        	System.debug('Check 1');
		        	System.debug('cR.TMN_Contact__r.Id: ' + cR.TMN_Contact__r.Id);
		        	System.debug('aMentorOrHouseholdMember.Id: ' + aMentor.Id);
		       		if(cR.TMN_Contact__c==aMentor.Id) {    	
			        	System.debug('Check 2');
			        	// Check to see if the credential record's TMN_Contact__c parent record belongs to a Mentor...        	
			        	if(cR.TMN_Contact__r.Id==cR.TMN_Contact__r.Household_Id__c) {
			        		// If it DOES, then we've had a NEW insert of each of the Credential_Record__c credential profiles represented by the incoming list.  A given contact should 
			        		// only ever have ONE record for any given Credential_Profile__c cred.  AFTER AN UPDATE, we DO care about the data in the records.
			
							// TEST OF MentorCredUpdate method call...
							//if(cR.Similar_Credentials__c!=null) {
							//	theseUpdates.add(MentorCredUpdate(cR, mentorsCredsToCompare, aMentor, aMentor, householdToUpdate));
							//}
							
							for(Mentor_Tracking_Metadata__c m : metaDataRecs) {
								System.debug('What is m.Credential_Profile__c: ' + m.Credential_Profile__c);
								System.debug('What is cR.Credential_Profile__c: ' + cR.Credential_Profile__c);
								if(m.Credential_Profile__c==cR.Credential_Profile__c) {
									theseUpdates.add(MentorCredUpdate2(cR, mentorsCredsToCompare, aMentor, aMentor, householdToUpdate, m));
								}
							}
						}
			        	// ELSE IF it's NOT a Mentor...
			        	else {
			        		System.debug('Check 5');
			        	}					
		       		}
	        	}
	        }
			
	        System.debug('Check ALPHA');
		    for(DhrUpdate2 dU : theseUpdates) {
	        	System.debug('Check BETA');
	        	System.debug('What is dU.dhrFieldForUpdate: ' + dU.dhrFieldForUpdate);
	        	System.debug('What is dU.dhrUpdateCred.get(dU.credRecSourceField): ' + dU.dhrUpdateCred.get(dU.credRecSourceField));
	        	theContactsReptRec.put(dU.dhrFieldForUpdate,dU.dhrUpdateCred.get(dU.credRecSourceField));
	        }
	        	        
	        for(TMN_Contact__c householdMember : householdToUpdate) {
	        	System.debug('Check DELTA');
	            for(Mentor_Tracking_Report_Record__c houseMemberReport : householdMembersRepts) {
        			System.debug('Check EPSILON');
        			if(householdMember.Id==houseMemberReport.TMN_Contact__r.Id){
	        			System.debug('Check ZETA');
	        			for(DhrUpdate2 dU2 : theseUpdates) {	        	
				        	System.debug('Check ETA');
				        	if(dU2.dhrUpdateMentor.Id==householdMember.Mentor__c && dU2.dhrUpdateCred.DHR_Scope__c=='Household') {
								System.debug('Check THETA');
								System.debug('What is dU2.dhrUpdateMentor.Id: ' + dU2.dhrUpdateMentor.Id);
								System.debug('What is householdMember.Mentor__c: ' + householdMember.Mentor__c);
								System.debug('Does dU2.dhrUpdateCred.DHR_Scope__c==\'Household\': ' + dU2.dhrUpdateCred.DHR_Scope__c);
								System.debug('What is the report field being updated: ' +  dU2.dhrFieldForUpdate);
								System.debug('What is the value going into the field: ' + dU2.dhrUpdateCred.get(dU2.credRecSourceField));
								houseMemberReport.put(dU2.dhrFieldForUpdate,dU2.dhrUpdateCred.get(dU2.credRecSourceField));
				        	}
				        	else if(dU2.dhrUpdateMentor.Id==householdMember.Mentor__c && dU2.dhrUpdateCred.DHR_Scope__c=='Self Adult, Mentor Minors' && householdMember.Age__c < 18) {
								houseMemberReport.put(dU2.dhrFieldForUpdate,dU2.dhrUpdateCred.get(dU2.credRecSourceField));
				        	}				        	
	        			}
        			reptsToUpdate.add(houseMemberReport);
        			}
        		}	        	
	        }
	        System.debug('Check GAMMA');
	    	reptsToUpdate.add(theContactsReptRec);
		}
		update reptsToUpdate;
		
		// Could possibly remove this second loop through the non-mentors in favor of one loop above that checks to see if TMN_Contact__c is a mentor, and branches accordingly.
		// Did this for now because it was easier for me to figure out.  J. Gilliam, 2/18/14
		List<DhrUpdate2> theseNonMentorUpdates = new List<DhrUpdate2>();		
		for(TMN_Contact__c aNonMentor : nonMentors) {
				System.debug('Who is aNonMentor: ' + aNonMentor);
	        	Mentor_Tracking_Report_Record__c theNonMentorsReptRec = new Mentor_Tracking_Report_Record__c();      	
	        	Mentor_Tracking_Report_Record__c checkForExistingReptRecNonMentor = new Mentor_Tracking_Report_Record__c();
	        	
	        	for(Mentor_Tracking_Report_Record__c r2 : reptsForTheNonMentors) {
	        		if(aNonMentor.Id==r2.TMN_Contact__c) {
	        				System.debug('Check 1');
	        			checkForExistingReptRecNonMentor = r2;
	        		}
	        	}
	        	
	        	
	        	// WORK TO CREATE THE REPORT RECORD FOR THIS MENTOR.  It stays in context until the aMentor for loop iterates.
	        	if(checkForExistingReptRecNonMentor==null) {
	        		System.debug('Check 2');
	        		// This should NEVER happen.  The initial insert of the Mentor_Tracking_Report_Record__c record is happening in the TMN_ContactHandler.cls  Seems
	        		// to make sense to insert a record if one is NOT present, though, so I'm leaving this.  The only case I think it MIGHT execute under is if a Disregarded TMN_Contact__c
	        		// is switched to Active or such.
	        		theNonMentorsReptRec.TMN_Contact__c = aNonMentor.Id;
	        		insert theNonMentorsReptRec;	
	        	}
	        	else {
	        		System.debug('Check 3');
	        		theNonMentorsReptRec = checkForExistingReptRecNonMentor;
	        	}			

				for(Credential_Record__c cR2 : theseCredRecs) {
					if(cR2.DHR_Scope__c!='N/A' && cR2.DHR_Scope__c!=null) {
						System.debug('Check 4');
		       			if(cR2.TMN_Contact__c==aNonMentor.Id) {
		       				System.debug('Check 5'); 
							//if(cR2.Similar_Credentials__c!=null) {
								System.debug('Check 6');
							for(Mentor_Tracking_Metadata__c m : metaDataRecs) {
								System.debug('What is m.Credential_Profile__c: ' + m.Credential_Profile__c);
								System.debug('What is cR.Credential_Profile__c: ' + cR2.Credential_Profile__c);
								if(m.Credential_Profile__c==cR2.Credential_Profile__c) {
									theseNonMentorUpdates.add(MentorCredUpdate2(cR2, nonMentorsCredsToCompare, aNonMentor, null, null, m));
								}
							}
							//}	       			
		       			}
					}
				}

		    for(DhrUpdate2 dUnm : theseNonMentorUpdates) {
				if(dUnm.dhrUpdateCred.DHR_Scope__c=='Self' || (dUnm.dhrUpdateCred.DHR_Scope__c=='Self Adult, Mentor Minors' && aNonMentor.Age__c >= 18)) {
					System.debug('Check 7');	        
		        	theNonMentorsReptRec.put(dUnm.dhrFieldForUpdate,dUnm.dhrUpdateCred.get(dUnm.credRecSourceField));
				}
	        }
	        System.debug('Check 10');
			reptsToUpdateNonMentor.add(theNonMentorsReptRec);
		}
		System.debug('Check 11');		  	
        update reptsToUpdateNonMentor;
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
    
///////////////////////////////////////////////////////
// METHODS FOR MENTOR TRACKING REPORT RECORD UPDATES //
///////////////////////////////////////////////////////  

	public DhrUpdate2 MentorCredUpdate2(Credential_Record__c theCred, List<Credential_Record__c> theMentorsCreds, TMN_Contact__c theContact, TMN_Contact__c theMentor, List<TMN_Contact__c> householdToUpdate, Mentor_Tracking_Metadata__c mtm) {
		System.debug('MentorCredUpdate2; theCred: ' + theCred);
		System.debug('MentorCredUpdate2; theMentorsCreds' + theMentorsCreds);

		
		Boolean goForUpdate = false;
		Boolean skip = false;
		Credential_Record__c winningCred = new Credential_Record__c();
		winningCred = theCred;
		
		Credential_Record__c parallelCredWinner1 = new Credential_Record__c();
		Credential_Record__c parallelCredWinner2 = new Credential_Record__c();
		parallelCredWinner1 = theCred;
		parallelCredWinner2 = theCred;
		
		Date currentMostRecentDate;

		// IF there are any parallel credentials listed...
			// THEN we have to see if any of those parallel credentials have similar credentials between which we must select.
			// If yes, then do what we do below.  If no, then move on to picking between the competing "groups (possibly of 1)" of credentials.
			if(mtm.Parallel_Credentials__c!=null) {
				if(mtm.Similar_Credentials__c!=null) {
					for(Credential_Record__c credBeta : theMentorsCreds) {
						if(credBeta.Credential_Profile__c==mtm.Superceded_By__c) {
							parallelCredWinner1 = theCred;
						}
						else if(credBeta.Credential_Profile__c==mtm.Supercedes__c) {
							parallelCredWinner1 = credBeta;
						}
						else {
							Date parallelCredWinner1Date = Date.valueOf(parallelCredWinner1.get(mtm.Credential_Record_Date_Field__c));
							Date credBetaDate = Date.valueOf(credBeta.get(mtm.Credential_Record_Date_Field__c));
							
							if(mtm.Similar_Credentials__c.contains('{~}' + credBeta.Credential_Profile_Name__c + '{~}')) {
								// Then do the comparison work to figure out if this other doc is more recent than the cred.
								System.debug('WIN ON SIM CRED MATCH!');
								
								
								System.debug('parallelCredWinner1.get(mtm.Credential_Record_Source_Field__c): ' + parallelCredWinner1.get(mtm.Credential_Record_Source_Field__c));
								
								
								if(theCred.get(mtm.Credential_Record_Date_Field__c)!=null){
									// Then use Documented_Date__c to determine which doc is more current.
									
									if(parallelCredWinner1Date < credBetaDate) {
										parallelCredWinner1 = credBeta;
									}
									else {
										parallelCredWinner1 = parallelCredWinner1;
									}
									
								}
							}
						}	
					}					
				}
				// After identifying the winning cred for the cred that got an update, we have to look at each parallel cred, and find the winner for each group of those.
				// NEED TO GET A LIST OF THE PARALLEL CREDS.  EXPLODE THE STRING INTO LIST.
				List<string> parallelCreds = new List<string>();
				parallelCreds = mtm.Parallel_Credentials__c.split(Pattern.quote('{~}'),0);
				// THEN, LOOP THROUGH THE LIST AND DO THE WIN/LOSE LOOP...FOR EACH MATCH???
				for(string pC : parallelCreds) {
					if(mtm.Similar_Credentials__c!=null) {
						for(Credential_Record__c credBeta : theMentorsCreds) {
							if(credBeta.Credential_Profile_Name__c==pC) {
								if(credBeta.Credential_Profile__c==mtm.Superceded_By__c) {
									parallelCredWinner2 = credBeta;
								}
								else if(credBeta.Credential_Profile__c==mtm.Supercedes__c) {
									parallelCredWinner2 = theCred;
								}
								else {
									Date parallelCredWinner2Date = Date.valueOf(parallelCredWinner2.get(mtm.Credential_Record_Date_Field__c));
									Date credBetaDate = Date.valueOf(credBeta.get(mtm.Credential_Record_Date_Field__c));
									
									if(mtm.Similar_Credentials__c.contains('{~}' + credBeta.Credential_Profile_Name__c + '{~}')) {
										// Then do the comparison work to figure out if this other doc is more recent than the cred.
										System.debug('WIN ON SIM CRED MATCH!');
										
										
										System.debug('parallelCredWinner2.get(mtm.Credential_Record_Source_Field__c): ' + parallelCredWinner2.get(mtm.Credential_Record_Source_Field__c));
										
										
										if(theCred.get(mtm.Credential_Record_Date_Field__c)!=null){
											// Then use Documented_Date__c to determine which doc is more current.
											
											if(parallelCredWinner2Date < credBetaDate) {
												parallelCredWinner2 = credBeta;
											}
											else {
												parallelCredWinner2 = parallelCredWinner2;
											}
											
										}
									}
								}
							}	
						}
					}
				}
				if(mtm.parallel_Credentials_Type__c=='OR') {
					if(parallelCredWinner1.get(mtm.Credential_Record_Source_Field__c)=='Yes' || parallelCredWinner2.get(mtm.Credential_Record_Source_Field__c)=='Yes') {
						if(parallelCredWinner1.get(mtm.Credential_Record_Source_Field__c)=='Yes') {
							winningCred = parallelCredWinner1;
						}
						else {
							winningCred = parallelCredWinner2;
						}
					}
					else {
						winningCred = parallelCredWinner1;
					}
				}
				else if(mtm.parallel_Credentials_Type__c=='AND') {
					if(parallelCredWinner1.get(mtm.Credential_Record_Source_Field__c)=='Yes' && parallelCredWinner2.get(mtm.Credential_Record_Source_Field__c)=='Yes') {
						winningCred = parallelCredWinner1;
					}
					else {
						if(parallelCredWinner1.get(mtm.Credential_Record_Source_Field__c)=='No') {
							winningCred = parallelCredWinner1;
						}
						else {
							winningCred = parallelCredWinner2;
						}
					}
				}
			}
		// ELSE IF there are no similar docs...
			else if(mtm.Similar_Credentials__c==null) {
				winningCred = winningCred; // Just pass through the original cred.
			}
		// ELSE IF there ARE similar docs...
			else if(mtm.Similar_Credentials__c!=null) {
				// Check to see if the Similar Doc(s) is also in the file
				for(Credential_Record__c credBeta : theMentorsCreds) {
					System.debug('credBeta: ' + credBeta);
					System.debug('mtm.Superceded_By__c: ' + mtm.Superceded_By__c);
					System.debug('mtm.Supercedes__c: ' + mtm.Supercedes__c);
					if(credBeta.Credential_Profile__c==mtm.Superceded_By__c) {
						winningCred = credBeta;
					}
					else if(credBeta.Credential_Profile__c==mtm.Supercedes__c) {
						winningCred = theCred;
					}
					else {
						Date winningCredDate = Date.valueOf(winningCred.get(mtm.Credential_Record_Date_Field__c));
						Date credBetaDate = Date.valueOf(credBeta.get(mtm.Credential_Record_Date_Field__c));
						
						if(mtm.Similar_Credentials__c.contains('{~}' + credBeta.Credential_Profile_Name__c + '{~}')) {
							// Then do the comparison work to figure out if this other doc is more recent than the cred.
							System.debug('WIN ON SIM CRED MATCH!');
							
							
							System.debug('winningCred.get(mtm.Credential_Record_Source_Field__c): ' + winningCred.get(mtm.Credential_Record_Source_Field__c));
							
							
							if(theCred.get(mtm.Credential_Record_Date_Field__c)!=null){
								// Then use Documented_Date__c to determine which doc is more current.
								
								if(winningCredDate < credBetaDate) {
									winningCred = credBeta;
								}
								else {
									winningCred = winningCred;
								}
								
							}
						}
					}	
				}
			}
	
		DhrUpdate2 thisUpdate = new DhrUpdate2(goForUpdate, winningCred, theContact, theMentor, householdToUpdate, mtm);
		
		return thisUpdate;
				
	} 

}