public with sharing class TMN_ContactHandler {
	
    private boolean m_isExecuting = false;

    public TMN_ContactHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

  /*  public void OnBeforeInsert(TMN_Contact__c[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
         SoundExTriggerUtil util= new SoundExTriggerUtil();
         util.generateKeys(System.trigger.new);
    }
*/
    public void OnAfterInsert(TMN_Contact__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
		
		// Put incoming list of TMN_Contact__c records into a more user-friendly variable name, and declare a variable for a list or TMN_Contact__c IDs. 
    	List<TMN_Contact__c> thesePersons = newObjects;
		List<Id> personIds = new List<Id>();

		Schema.DescribeSObjectResult personSchemaInfo = TMN_Contact__c.SObjectType.getDescribe();
		List<Schema.RecordTypeInfo> personRecordTypes = personSchemaInfo.getRecordTypeInfos();
    
        // Get ALL credential profiles into a list so we can later filter out only the ones for a given new person's 'type' without putting a query in a loop.
        List<Credential_Profile__c> credList = new List<Credential_Profile__c>();
        credList = [ SELECT Id, Name, Required_for_Mentor__c, Optional_for_Mentor__c, Required_for_Co_Applicant__c, Optional_for_Co_Applicant__c, 
        			Required_for_Foster_Parent_Relative__c, Optional_for_Foster_Parent_Relative__c, Required_for_Foster_Parent_Child__c, 
        			Optional_for_Foster_Parent_Child__c, Required_for_Resident_Non_Relative__c, Optional_for_Resident_Non_Relative__c,
        			Required_for_Pet__c, Optional_for_Pet__c, Needed_for_Under_18__c, Needed_for_18_Over__c FROM Credential_Profile__c ];
       System.debug('credList holds: ' + credList);
       
       // Loop through the person records that were just created, and determine which Credential_Profile__c records matter for them, based on the TMN_Contact__c        
		for (TMN_Contact__c p : thesePersons) {
       		System.debug('The persons loop in PersonHandler.cls is executing...');
       		System.debug('What is p in the persons loop in PersonHandler.cls: ' + p);
			
			Mentor_Tracking_Report_Record__c thisContactsReptRec = new Mentor_Tracking_Report_Record__c(
       			TMN_Contact__c = p.Id,
       			Mentor__c = p.Mentor__c,
       			Status__c = 'New'
       		);
       		

       		
       		
			if(p.Disregarded__c!=true) {
       			insert thisContactsReptRec;
       		}
       		
			
			string thisPersonsRecordTypeName;

   			for(Schema.RecordTypeInfo sPrts : personRecordTypes) {
   				System.debug('sPrts.Name: ' + sPrts.Name);
   				System.debug('p.RecordTypeId: ' + p.RecordTypeId);
   				System.debug('sPrts.RecordTypeId: ' + sPrts.RecordTypeId);
   				if(p.RecordTypeId==sPrts.RecordTypeId) {
   					thisPersonsRecordTypeName = sPrts.Name;
   				}
   			}

       		// Initialize a list variable for the credential records we'll eventually insert for each person.
       		List<Credential_Record__c> credRecs = new List<Credential_Record__c>();
       		
       		for(Credential_Profile__c cp : credList) {
       			System.debug('This person\'s Record Type ID is: ' + p.RecordTypeId);
       			System.debug('This person\'s RecordType.Name is: ' + p.RecordType.Name);
       			System.debug('This credential\'s cp.Required_for_Mentor__c value is: ' + cp.Required_for_Mentor__c);
       			if(thisPersonsRecordTypeName=='Mentor' && cp.Required_for_Mentor__c==true) {
   					Credential_Record__c credRec = new Credential_Record__c(
   						Credential_Profile__c = cp.Id,
   						TMN_Contact__c = p.Id
   					);			
   					credRecs.add(credRec);
   					System.debug('Added a Credential Record (' + cp.Name + ') to credRecs for a \'Mentor\' Record Type...');
       			}
       			if(thisPersonsRecordTypeName=='Household Member') {
	   				if(p.Related_Party_Type__c=='Co-Applicant' && cp.Required_for_Co_Applicant__c==true) {
	   					Credential_Record__c credRec = new Credential_Record__c(
	   						Credential_Profile__c = cp.Id,
	   						TMN_Contact__c = p.Id
	   					);			
	   					credRecs.add(credRec);
       				}
	   				if(p.Related_Party_Type__c=='Foster Parent\'s Relative' && p.Age__c < 18 && cp.Required_for_Foster_Parent_Relative__c==true && cp.Needed_for_Under_18__c==true) {
	   					Credential_Record__c credRec = new Credential_Record__c(
	   						Credential_Profile__c = cp.Id,
	   						TMN_Contact__c = p.Id
	   					);			
	   					credRecs.add(credRec);
       				}
	   				if(p.Related_Party_Type__c=='Foster Parent\'s Relative' && p.Age__c >= 18 && cp.Required_for_Foster_Parent_Relative__c==true && cp.Needed_for_18_Over__c==true) {
	   					Credential_Record__c credRec = new Credential_Record__c(
	   						Credential_Profile__c = cp.Id,
	   						TMN_Contact__c = p.Id
	   					);			
	   					credRecs.add(credRec);
       				}
	   				if(p.Related_Party_Type__c=='Foster Parent\'s Child' && p.Age__c < 18 && cp.Required_for_Foster_Parent_Child__c==true && cp.Needed_for_Under_18__c==true) {
	   					Credential_Record__c credRec = new Credential_Record__c(
	   						Credential_Profile__c = cp.Id,
	   						TMN_Contact__c = p.Id
	   					);			
	   					credRecs.add(credRec);
       				}
	   				if(p.Related_Party_Type__c=='Foster Parent\'s Child' && p.Age__c >= 18 && cp.Required_for_Foster_Parent_Child__c==true && cp.Needed_for_18_Over__c==true) {
	   					Credential_Record__c credRec = new Credential_Record__c(
	   						Credential_Profile__c = cp.Id,
	   						TMN_Contact__c = p.Id
	   					);			
	   					credRecs.add(credRec);
       				}
	   				if(p.Related_Party_Type__c=='Resident-Non Relative' && p.Age__c < 18 && cp.Required_for_Resident_Non_Relative__c==true && cp.Needed_for_Under_18__c==true) {
	   					Credential_Record__c credRec = new Credential_Record__c(
	   						Credential_Profile__c = cp.Id,
	   						TMN_Contact__c = p.Id
	   					);			
	   					credRecs.add(credRec);
       				}
	   				if(p.Related_Party_Type__c=='Resident-Non Relative' && p.Age__c >= 18 && cp.Required_for_Resident_Non_Relative__c==true && cp.Needed_for_18_Over__c==true) {
	   					Credential_Record__c credRec = new Credential_Record__c(
	   						Credential_Profile__c = cp.Id,
	   						TMN_Contact__c = p.Id
	   					);			
	   					credRecs.add(credRec);
       				}
	   				if(p.Related_Party_Type__c=='Pet' && cp.Required_for_Pet__c==true) {
	   					Credential_Record__c credRec = new Credential_Record__c(
	   						Credential_Profile__c = cp.Id,
	   						TMN_Contact__c = p.Id
	   					);			
	   					credRecs.add(credRec);
       				}       				 
       			}    			
       		}
       		insert credRecs; 
       		     
       }       
        
    }

  /*  public void OnBeforeUpdate(TMN_Contact__c[] oldObjects, TMN_Contact__c[] updatedObjects, Map<Id,TMN_Contact__c> newObjMap){
        // BEFORE UPDATE LOGIC 	
         SoundExTriggerUtil util= new SoundExTriggerUtil();
    	 util.generateKeys(System.trigger.new);
    }
*/
    public void OnAfterUpdate(TMN_Contact__c[] oldObjects, TMN_Contact__c[] updatedObjects, Map<Id,TMN_Contact__c> newObjMap){
        // AFTER UPDATE LOGIC

		//////
		//START: MENTOR TRACKING MSR REPORT STATUS HANDLING 
    	//////	
 		
 		List<TMN_Contact__c> theseTmnContactsRecordTypeDevNames = [ SELECT RecordType.DeveloperName FROM TMN_Contact__c WHERE Id = :updatedObjects ];
 
        List<TMN_Contact__c> mentors = new List<TMN_Contact__c>();
        List<TMN_Contact__c> nonMentors = new List<TMN_Contact__c>();       
        for(TMN_Contact__c tmnContact : updatedObjects) {
        	for(TMN_Contact__c devName : theseTmnContactsRecordTypeDevNames) {
        		if(tmnContact.Id==devName.Id) {
		        	System.debug('What is devName.RecordType.DeveloperName: ' + devName.RecordType.DeveloperName);
		        	if(devName.RecordType.DeveloperName=='Mentor') {
		        		mentors.add(tmnContact);
		        	}
		        	if(devName.RecordType.DeveloperName!='Mentor') {
		        		nonMentors.add(tmnContact);	
		        	}
        		}
        	}
    	}
    	
    	Map<TMN_Contact__c,List<TMN_Contact__c>> mentorToHouseholdMembers = new Map<TMN_Contact__c,List<TMN_Contact__c>>();
    	List<TMN_Contact__c> householdMemberList = [ SELECT Mentor__c FROM TMN_Contact__c WHERE Mentor__c = :updatedObjects ];
    	for(TMN_Contact__c m : mentors) {
    		List<TMN_Contact__c> thisHouseholdsMembers = new List<TMN_Contact__c>();
	    	for(TMN_Contact__c hM : householdMemberList) {
	    		if(hM.Mentor__c==m.Id) {
	    			thisHouseholdsMembers.add(hM);
	    		}
	    	}
	    	mentorToHouseholdMembers.put(m,thisHouseholdsMembers);
    	}

		List<Mentor_Tracking_Report_Record__c> dhrReportRecordsForAllTmnContactsAndHouseholdMembersThisUpdate = [ SELECT TMN_Contact__c, Status__c, Mentor__c, TMN_Contact__r.No_Longer_In_Home__c 
																													FROM Mentor_Tracking_Report_Record__c 
																													WHERE TMN_Contact__c = :updatedObjects OR Mentor__c = :updatedObjects ];
        List<Mentor_Tracking_Report_Record__c> dhrReportRecordsForMentors = new List<Mentor_Tracking_Report_Record__c>();
        List<Mentor_Tracking_Report_Record__c> dhrReportRecordsForMentorsHouseholdMembers = new List<Mentor_Tracking_Report_Record__c>();
        List<Mentor_Tracking_Report_Record__c> dhrReportRecordsForNonMentors = new List<Mentor_Tracking_Report_Record__c>();        
        for(Mentor_Tracking_Report_Record__c dhrRec : dhrReportRecordsForAllTmnContactsAndHouseholdMembersThisUpdate) {
			System.debug('TMN_Contact__c this loop: ' + dhrRec.TMN_Contact__c);
			for(TMN_Contact__c t : mentors) {
				System.debug('A Mentor: ' + t.Full_Name__c);
				if(t.Id==dhrRec.TMN_Contact__c) {
					dhrReportRecordsForMentors.add(dhrRec);
				}	
			}
			for(TMN_Contact__c t : nonMentors) {
				System.debug('A Non-Mentor: ' + t.Full_Name__c);
				if(t.Id==dhrRec.TMN_Contact__c) {
					dhrReportRecordsForNonMentors.add(dhrRec);
				}	
			}
			if(dhrRec.Mentor__c!=null) {
				dhrReportRecordsForMentorsHouseholdMembers.add(dhrRec);
			}	
        }
        
        List<Mentor_Tracking_Report_Record__c> dhrReportsToUpdate = new List<Mentor_Tracking_Report_Record__c>();
        
        
        // I think this will break if we ever get an update of a list of TMN_Contact__c records that includes both mentors and non-mentors, if the non-mentors are household members
        // of any of the submitted mentors.  If we start getting errors around the same member being added to a list multiple times, come back to this and extract the .add calls
        // from the nested for loops, etc.  J. Gilliam, 2/24/14.
		for(TMN_Contact__c t : updatedObjects) {
			for(Mentor_Tracking_Report_Record__c mentor : dhrReportRecordsForMentors) {
				if(t.Id==mentor.TMN_Contact__c) {
					if(t.Inactive__c==true) {
						System.debug('t.Inactive__C==true');
						if(mentor.Status__c!='Closed') {
							System.debug('Setting mentor.Status__c to Closed');
							mentor.Status__c = 'Closed';
							mentor.Skip_Trigger__c = true;
						}
						List<Mentor_Tracking_Report_Record__c> dhrReportUpdatesThisHouseholdLoop = new List<Mentor_Tracking_Report_Record__c>();	
						for(Mentor_Tracking_Report_Record__c householdMember : dhrReportRecordsForMentorsHouseholdMembers) {
							if(t.Id==householdMember.Mentor__c) {
								if(householdMember.Status__c!='Closed') {
									householdMember.Status__c = 'Closed';
									householdMember.Skip_Trigger__c = true;
								}
								dhrReportUpdatesThisHouseholdLoop.add(householdMember);
							}
						}
						update dhrReportUpdatesThisHouseholdLoop;
					}
					if(t.Active__c==true || t.Suspended__c==true || t.In_Progress__c==true) {
						System.debug('STATUS IS ACTIVE, SUSPENDED, OR IN PROGRESS');
						if(mentor.Status__c=='Closed') {
							mentor.Status__c = 'Updated';
							mentor.Submitted_Once_Closed__c = false;
						}
						List<Mentor_Tracking_Report_Record__c> dhrReportUpdatesThisHouseholdLoop2 = new List<Mentor_Tracking_Report_Record__c>();	
						for(Mentor_Tracking_Report_Record__c householdMember : dhrReportRecordsForMentorsHouseholdMembers) {
							if(t.Id==householdMember.Mentor__c) {
								if(householdMember.Status__c=='Closed' && householdMember.TMN_Contact__r.No_Longer_In_Home__c==false) {
									householdMember.Status__c = 'Updated';
									householdMember.Submitted_Once_Closed__c = false;
								}
								else if(householdMember.Status__c=='Closed' && householdMember.TMN_Contact__r.No_Longer_In_Home__c==true) {
									householdMember.Skip_Trigger__c = true;
								}
								dhrReportUpdatesThisHouseholdLoop2.add(householdMember);
							}
						}
						update dhrReportUpdatesThisHouseholdLoop2;
					}
				}
				dhrReportsToUpdate.add(mentor);
			}
			for(Mentor_Tracking_Report_Record__c nonMentor : dhrReportRecordsForNonMentors) {
				if(t.Id==nonMentor.TMN_Contact__c) {
					System.debug('t.Id==nonMentor.TMN_Contact__c');
					if(t.No_Longer_In_Home__c==true) {
						System.debug('t.No_Longer_In_Home__c==true');
						if(nonMentor.Status__c!='Closed') {
							nonMentor.Status__c = 'Closed';
							nonMentor.Skip_Trigger__c = true;
							dhrReportsToUpdate.add(nonMentor);
						}
					}
					if(t.No_Longer_In_Home__c==false) {
						if(nonMentor.Status__c=='Closed') {
							nonMentor.Status__c = 'Updated';
							nonMentor.Submitted_Once_Closed__c = false;
							dhrReportsToUpdate.add(nonMentor);
						}
					}
				}	
			}
		}
		
		update dhrReportsToUpdate;
		
		//////
		//END: MENTOR TRACKING MSR REPORT STATUS HANDLING
    	//////	
    
    	/////////////////////////////////////////////////////////////////////////////
    	/////////////////////////////////////////////////////////////////////////////
    
		//////
		//START: MENTOR TRACKING TMN_CONTACT__C OWNERSHIP
		//////    

		for(TMN_Contact__c t : mentors) {
			for(TMN_Contact__c tUpdate : updatedObjects) {
				if(t.Id==tUpdate.Id) {  // If the record being updated is a Mentor...
					for(TMN_Contact__c tOld : oldObjects) {
						if(tUpdate.Id==tOld.Id && tUpdate.OwnerId!=tOld.OwnerId) { //...and the old owner for the contact doesn't equal the new owner
							List<TMN_Contact__c> theseHouseholdMembers = mentorToHouseholdMembers.get(t);
							List<TMN_Contact__c> householdMembersToUpdate = new List<TMN_Contact__c>();
							for(TMN_Contact__c thisHouseholdMember : theseHouseholdMembers) {
								thisHouseholdMember.OwnerId = tUpdate.OwnerId;
								householdMembersToUpdate.add(thisHouseholdMember);	
							}
							try {
								update householdMembersToUpdate;
							}
							catch(DmlException e) {
								System.debug('The following exception has occurred: ' + e.getMessage());
							}
						}
					}
				}
			}
		}

		//////
		//END: MENTOR TRACKING TMN_CONTACT__C OWNERSHIP
		//////    
    
    }

    public void OnBeforeDelete(TMN_Contact__c[] ObjectsToDelete, Map<Id,TMN_Contact__c> oldObjMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(TMN_Contact__c[] deletedObjects, Map<Id,TMN_Contact__c> oldObjMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(TMN_Contact__c[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

}