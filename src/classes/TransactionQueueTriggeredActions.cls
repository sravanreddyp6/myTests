// trigger code to support user inserting a row into the transaction queue
// based on the request type, the code will do the work of getting/putting the data requested with given input params
// once transaction is complete, result is serialized for return to caller with result code and fulfillment date put into queue request for audit purposes
// class is being run without sharing for full data visibility *** this can be changed by request type if necessary

public without sharing class TransactionQueueTriggeredActions {
	public void afterUpdate(List<Transaction_Queue__c> txns) {

			system.debug('Running as: ' + UserInfo.getUserName() );
			system.debug('Number of Transactions to process : ' + txns.size() );
			Transaction_Queue__c newreq;

			// need to bulkify?
			for (Transaction_queue__c t : txns ) {

				if ( t.fulfilled__c ) // prevents re-entry
					return;

								// create a Txn Queue object that will be used to update the one whose trigger we are currently in
				newreq = new Transaction_Queue__c( id = t.ID, received_date_time__c = DateTime.Now());

				if ( t.request_type__c == 'Action Plan' ) {

					try {
						// get the pbs id from the request pararms
						ID APId = t.input_params__c;

						// execute the transaction as requested
						// make sure it still exists
						Action_plan__c ap = [ select id, name, status__c, service_assignment__c from action_plan__c where id= :APId and status__c='Active Final' LIMIT 1];
	                    ActionPlan_FormWithoutSharing apWithoutSharing = new ActionPlan_FormWithoutSharing(ap.id);

						// serialize the result
						String jsonstring = json.serialize( apWithoutSharing );
						//system.debug( 'GOT RESULT: '  + jsonstring);

						// break up the string if necessary
						storeResultString( newreq, jsonstring );

						// update the request as having been fulfilled
						newreq.fulfilled__c = true;
						newreq.Date_Time_Fulfilled__c = DateTime.Now();

					}
					catch (Exception e) {
						// flag the error
						newreq.fulfilled__c = false;
						newreq.return_value__c = json.serialize( e.getMessage() );
						throw(e);
						return;
					}

				}

                else if ( t.request_type__c == 'Person Being Served' ) {
                    try {
                        // get the pbs id from the request pararms
                        ID PBSid = t.input_params__c;
                        // execute the transaction as requested
                        DSPPersonBeingServed_WithoutSharing pbsWithoutSharing = new DSPPersonBeingServed_WithoutSharing(PBSid);

                        // serialize the result
                        String jsonstring = json.serialize( pbsWithoutSharing );
                        system.debug( 'GOT RESULT: '  + jsonstring);

                        // break up the string if necessary
						storeResultString( newreq, jsonstring );

                        // update the request as having been fulfilled
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
	                } catch ( Exception e ) {
	//                          newreq.return_code__c = 'ERROR';
                            system.debug( e );
                            newreq.fulfilled__c = false;
                            newreq.return_value__c = json.serialize( e.getMessage() );
                           	throw(e);
							return;
					}
                }

                else if ( t.request_type__c == 'Risk' ) {
                    try {
                        // get the pbs id from the request pararms
                        ID idInputParam = t.input_params__c;
                        Id assessmentId;
                        if (idInputParam.getSObjectType().getDescribe().getName() == 'Assessment__c'){
                            assessmentId = idInputParam;
                        } else {
	                        assessmentId = [ select id from Assessment__c where Admission__c = :idInputParam and status__c= 'Active Final' and Assessment_Type__r.name = 'Risk' limit 1].id;
                        }

                        // execute the transaction as requested
                        Assessment_RiskFormWithoutSharing riskAssessment = new Assessment_RiskFormWithoutSharing(assessmentId);

                        // serialize the result
                        String jsonstring = json.serialize(riskAssessment);
                        //system.debug( 'GOT RESULT: '  + jsonstring);

						// break up the string if necessary
						storeResultString( newreq, jsonstring );

                        // update the request as having been fulfilled
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();

                    } catch (Exception e) {
                        // flag the error
                        newreq.fulfilled__c = false;
                        newreq.return_value__c = json.serialize( e.getMessage() );
                        throw(e);
						return;
                    }

                }

                else if ( t.request_type__c == 'ISSA' ) {
                    try {
                        // get the pbs id from the request pararms
                        ID idInputParam = t.input_params__c;
                        Id assessmentId;
                        if (idInputParam.getSObjectType().getDescribe().getName() == 'Assessment__c'){
                            assessmentId = idInputParam;
                        } else {
                            assessmentId = [select id from Assessment__c where Admission__c = :idInputParam and status__c= 'Active Final' and Type__c = 'ISSA' limit 1].id;
                        }

                        // execute the transaction as requested
                        Assessment_IssaFormWithoutSharing issaAssessment = new Assessment_IssaFormWithoutSharing(assessmentId);

                        // serialize the result
                        String jsonstring = json.serialize(issaAssessment);
                        //system.debug( 'GOT RESULT: '  + jsonstring);

						// break up the string if necessary
						storeResultString( newreq, jsonstring );

                        // update the request as having been fulfilled
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();

                    } catch (Exception e) {
                        // flag the error
                        newreq.fulfilled__c = false;
                        newreq.return_value__c = json.serialize( e.getMessage() );
                        throw(e);
						return;
                    }

                }

                else if ( t.request_type__c == 'Acknowledge Assessment') {
                    try {
                        // get the pbs id from the request pararms
                        ID idInputParam = t.input_params__c;
                        Id assessmentId;
                        DSP_AssessmentResponseType assessmentDetails;
                        String assessmentType = ApexPages.currentPage().getUrl().containsIgnoreCase('DSP_Assessment_RiskForm') ? 'Risk' : 'ISSA';

                        if (idInputParam.getSObjectType().getDescribe().getName() == 'Assessment__c'){
                            assessmentId = idInputParam;
                        }else{
	                        if (assessmentType == 'Risk') assessmentId = [ select id from Assessment__c where Admission__c = :idInputParam and status__c= 'Active Final' and Assessment_Type__r.name = 'Risk' limit 1].id;
	                        else  assessmentId = [ select id from Assessment__c where Admission__c = :idInputParam and status__c= 'Active Final' and Type__c = 'ISSA' limit 1].id;
                        }
                        Acknowledgment__c confirmRec = new Acknowledgment__c(Assessment__c = assessmentId, User__c = UserInfo.getUserId());
                        insert confirmRec;

                        if (assessmentType == 'Risk') assessmentDetails = new Assessment_RiskFormWithoutSharing(assessmentId);
                        else assessmentDetails = new Assessment_IssaFormWithoutSharing(assessmentId);

                        // serialize the result
                        String jsonstring = json.serialize( assessmentDetails );

                        // break up the string if necessary
						storeResultString( newreq, jsonstring );

                        // update the request as having been fulfilled
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
//                          newreq.return_code__c = 'ERROR';
                            system.debug( e );
                            newreq.fulfilled__c = false;
                            newreq.return_value__c = json.serialize( e.getMessage() );
                            throw(e);
							return;
                    	}
                }
                else if ( t.request_type__c == 'Seizures' ) {
                    try {
                        // get the pbs id from the request pararms
                        ID PBSid = t.input_params__c;
                        // execute the transaction as requested
                        DSP_PbsSeizureListing dsp_PbsSeizureListing = new DSP_PbsSeizureListing(PBSid);

                        // serialize the result
                        String jsonstring = json.serialize( dsp_PbsSeizureListing );
                        //system.debug( 'GOT RESULT: '  + jsonstring);

						// break up the string if necessary
						storeResultString( newreq, jsonstring );

                        // update the request as having been fulfilled
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
    //                          newreq.return_code__c = 'ERROR';
                                system.debug( e );
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
                                throw(e);
								return;
                    }
                }
                else if ( t.request_type__c == 'Upsert Seizure' ) {
                    try {
                            Seizure__c inputs = (Seizure__c) json.deserialize(t.input_params__c, Seizure__c.class);
                            upsert inputs;
                            Id PBSid = [select Admission__r.Person_Being_Served__c from Service_Assignment__c where id = : inputs.Service_Assignment__c limit 1].Admission__r.Person_Being_Served__c;

                            DSP_PbsSeizureListing dsp_PbsSeizureListing = new DSP_PbsSeizureListing(PBSid);
                            // serialize the result
                            String jsonstring = json.serialize( dsp_PbsSeizureListing );

                            // break up the string if necessary
							storeResultString( newreq, jsonstring );

                            // update the request as having been fulfilled
                            newreq.fulfilled__c = true;
                            newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
//                          newreq.return_code__c = 'ERROR';
                            system.debug( e );
                            newreq.fulfilled__c = false;
                            newreq.return_value__c = json.serialize( e.getMessage() );
                         	throw(e);
							return;
                    }
                }
				else if ( t.request_type__c == 'Acknowledge Plan') {
					try {
							// get the action plan id and initials from the request pararms
							system.debug( t.input_params__c);
							Map<String, String> inputs = (Map<string, string>) json.deserialize(t.input_params__c, Map<String, String>.class);

							// execute the transaction as requested
							Acknowledgment__c a = new Acknowledgment__c ( action_plan__c = inputs.get('Action_plan__c'), initials__c = inputs.get('initials__c'), user__c = Userinfo.getUserId(), date_acknowledged__c = Date.today());
							system.debug ('ack record:' + a);
							insert a;

							// go get the refreshed view of the action plan
							Action_plan__c ap = [ select id, name, status__c, service_assignment__c from action_plan__c where id = :inputs.get('Action_plan__c') LIMIT 1];
	                    	ActionPlan_FormWithoutSharing apWithoutSharing = new ActionPlan_FormWithoutSharing(ap.id);

							// serialize the result
							String jsonstring = json.serialize( apWithoutSharing );
							system.debug( 'GOT RESULT: '  + jsonstring);

							// break up the string if necessary
							storeResultString( newreq, jsonstring );

							// update the request as having been fulfilled
							newreq.fulfilled__c = true;
							newreq.Date_Time_Fulfilled__c = DateTime.Now();


					} catch ( Exception e ) {
//							newreq.return_code__c = 'ERROR';
							system.debug( e );
							newreq.fulfilled__c = false;
							newreq.return_value__c = json.serialize( e.getMessage() );
                        	throw(e);
							return;
					}
				}
				else if ( t.request_type__c == 'BehaviorList' || t.request_type__c == 'SkillList' ) {
                    try {
                    	system.debug('TXN TYPE:' + t.request_type__c);
                        // get the Action plan id from the request pararms
                        ID APId = t.input_params__c;

                        // execute the transaction as requested
                        DSP_Worksheets worksheets  = new DSP_Worksheets(APId);

                        // serialize the result
                        String jsonstring = json.serialize( worksheets );
                        system.debug( 'GOT RESULT: '  + jsonstring);

						// break up the string if necessary
						storeResultString( newreq, jsonstring );

                        // update the request as having been fulfilled
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
    //                          newreq.return_code__c = 'ERROR';
                                system.debug( e );
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
                        		throw(e);
								return;
					}

                }

                else if ( t.request_type__c == 'Skill') {
                	try {
                		ID inputID = t.input_params__c;
                		ID wksheetID;

                		// if the id is an action plan and we need to create a new worksheet first
                		if ( inputID.getSObjectType().getDescribe().Name == 'Action_Plan__c') {
                			// start date is Monday of this week
                			Date sd = Date.Today().toStartofWeek() +1;
                			RecordType rt = [ select id from recordtype where sobjecttype = 'Action_Plan_Worksheet__c' and developername = 'Weekly_Skill_Result' LIMIT 1];
                			Action_Plan_Worksheet__c newsheet = new Action_Plan_Worksheet__c( Action_Plan__c = inputID, start_date__c = sd, recordtypeid = rt.Id);
                			insert newsheet;
                			wksheetID = newsheet.id;
                		} else {
                			wksheetID = inputID;
                		}

                		DSP_WeeklySkillTracking wksht = new DSP_WeeklySkillTracking( wksheetid );

                		String jsonstring = json.serialize( wksht);
                		storeResultSTring( newreq, jsonstring );

                        // update the request as having been fulfilled
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
    //                          newreq.return_code__c = 'ERROR';
                                system.debug( e );
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
                        		throw(e);
								return;
                    }

                }
                else if ( t.request_type__c == 'Update Skill') {

                	// get the worksheet id and updated data from the request pararms
					system.debug( t.input_params__c);
					Map<String, String> inputs = (Map<string, string>) json.deserialize(t.input_params__c, Map<String, String>.class);

					system.debug( 'WORKSHEET ID: ' + inputs.get('Action_plan_worksheet__c'));
					system.debug( 'ASR LIST: ' + json.deserialize(inputs.get('action_skill_results'), List<DSP_WeeklySkillTracking.ASRWrapper>.class));

					ID wksheetId = inputs.get('Action_plan_worksheet__c');

					List<DSP_WeeklySkillTracking.ASRWrapper> ASRs = (List<DSP_WeeklySkillTracking.ASRWrapper>)json.deserialize(inputs.get('action_skill_results'), List<DSP_WeeklySkillTracking.ASRWrapper>.class);

					// update the action skill results that correspond to what was passed in
					List<Action_Skill_Result__c> toUpd = new List<Action_Skill_Result__c>();

					for ( DSP_WeeklySkillTracking.ASRWrapper a : ASRs ) {
						Action_Skill_Result__c newResult = new Action_Skill_Result__c();
						newResult.action_plan_objective__c = a.oid;
						newResult.id = a.id;
						newResult.attempts__c = a.attempts;
						newResult.status__c = a.status;
						newResult.met_objective__c = a.met;
						newResult.initials__c = a.initials;
						newResult.day__c = a.day;

						toUpd.add( newResult);
					}

					try {
						upsert( toUpd);

             	  		DSP_WeeklySkillTracking wksht = new DSP_WeeklySkillTracking( wksheetId );

                		String jsonstring = json.serialize( wksht);
                		storeResultString( newreq, jsonstring );

                        // update the request as having been fulfilled
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
//                      newreq.return_code__c = 'ERROR';
                        system.debug( e );
                        newreq.fulfilled__c = false;
                        newreq.return_value__c = json.serialize( e.getMessage() );
                    	throw(e);
						return;
                    }
                }
                else if ( t.request_type__c == 'Behavior') {
                	try {
                		List<String> ids = t.input_params__c.split(',');
                		ID inputID;
                		ID wksheetID;
                		ID objID = null;

                		if ( ids.size() == 1 ) {
                			inputID = (ID)ids[0];

	                		// if the id is an action plan and we need to create a new worksheet first
	                		if ( inputID.getSObjectType().getDescribe().Name == 'Action_Plan__c') {
	                			// start date is Monday of this week
	                			Date sd = Date.Today().toStartofMonth();
	                			RecordType rt = [ select id from recordtype where sobjecttype = 'Action_Plan_Worksheet__c' and developername = 'Monthly_Behavior_Result' LIMIT 1];
	                			Action_Plan_Worksheet__c newsheet = new Action_Plan_Worksheet__c( Action_Plan__c = inputID, start_date__c = sd, recordtypeid = rt.Id);
	                			insert newsheet;
	                			wksheetID = newsheet.id;
	                		} else {
	                			wksheetID = inputID;
	                		}
                		} else {
                			wksheetID = ids[0];
                			objID = ids[1];
                		}

                		DSP_BehaviorTracking wksht = new DSP_BehaviorTracking( wksheetid, objID);

                		String jsonstring = json.serialize( wksht);
                		storeResultSTring( newreq, jsonstring );

                        // update the request as having been fulfilled
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
    //                          newreq.return_code__c = 'ERROR';
                                system.debug( e );
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
                        		throw(e);
								return;
                    }

                }

                else if ( t.request_type__c == 'Update Behavior') {

                	// get the worksheet id and updated data from the request pararms
					system.debug( t.input_params__c);
					Map<String, String> inputs = (Map<string, string>) json.deserialize(t.input_params__c, Map<String, String>.class);

					//system.debug( 'WORKSHEET ID: ' + inputs.get('Action_plan_worksheet__c'));
					//system.debug( 'NEW TARGET ID: ' + inputs.get('newid'));
					//system.debug( 'JSON for results: ' + inputs.get('behavior_results'));
					//system.debug( 'ABR LIST: ' + json.deserialize(inputs.get('behavior_results'), List<DSP_BehaviorTracking.ABRWrapper>.class));

					ID wksheetId = inputs.get('Action_plan_worksheet__c');
					ID newID = inputs.get('newid');

					List<DSP_BehaviorTracking.ABRWrapper> ABRs = (List<DSP_BehaviorTracking.ABRWrapper>)json.deserialize(inputs.get('behavior_results'), List<DSP_BehaviorTracking.ABRWrapper>.class);

					// update the action skill results that correspond to what was passed in
					List<Action_Behavior_Result__c> toUpd = new List<Action_Behavior_Result__c>();
					ID ObjID;
					for ( DSP_BehaviorTracking.ABRWrapper a : ABRs ) {
						Action_Behavior_Result__c newResult = new Action_Behavior_Result__c();
						newResult.action_plan_objective__c = a.oid;
						newResult.id = a.id;
						if ( a.occurrences != null )
							newResult.occurrences__c = a.occurrences;

						if ( a.occurred != null)
							newResult.occurred__c = a.occurred;

						newResult.day_time__c = a.daytime;
						objID = a.oid;
						toUpd.add( newResult);
					}

					try {
						upsert( toUpd);

             	  		DSP_BehaviorTracking wksht = new DSP_BehaviorTracking( wksheetId,  newid);

                		String jsonstring = json.serialize( wksht);
                		storeResultString( newreq, jsonstring );

                        // update the request as having been fulfilled
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
//                      newreq.return_code__c = 'ERROR';
                        system.debug( e );
                        newreq.fulfilled__c = false;
                        newreq.return_value__c = json.serialize( e.getMessage() );
                    	throw(e);
						return;
                    }
                }
                else if ( t.request_type__c == 'Shift Note List') {
                    try {
                        ID pbsId = (ID) t.input_params__c;
                        DSP_ShiftNoteList shiftNote = new DSP_ShiftNoteList(pbsId);
                        String jsonstring = json.serialize( shiftNote);
                        storeResultSTring( newreq, jsonstring );
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
                                system.debug( e );
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
                                throw(e);
                                return;
                    }
                }
                else if ( t.request_type__c == 'Shift Note') {
                    try {
                        String inputs = t.input_params__c; // this is the comma separated list of ap,sa,admId,pbsid from the home page to create a new Shift Note, and just the id to view shift note detail form the list view
                        DSP_Shift_Note_Basic shiftNote = new DSP_Shift_Note_Basic(inputs);
                        String jsonstring = json.serialize( shiftNote);
                        storeResultSTring( newreq, jsonstring );
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
                                throw(e);
                                return;
                    }
                }
                else if ( t.request_type__c == 'Update Shift Note') {
                    try {
                        Map<String, String> inputs = (Map<string, string>) json.deserialize(t.input_params__c, Map<String, String>.class);
                        // upsert the shift note
                        Progress_Note__c pn = (Progress_Note__c) json.deserialize(inputs.get('payload.Note'), Progress_Note__c.class);
                        upsert(pn);

                        // insert-delete association with the goal-obj
                        //if goalObjective list is empty or if not the list of Id's, then delete exsting associations and there wont be anything to insert.
                        list<String> items = (list<String>) json.deserialize(inputs.get('payload.goalObjectAssociations'), list<String>.class);
                        boolean processAssociations = items != null && items.size() > 0 && items[0] instanceof id ;  //

                        List<ProgressNote_ActionPlanChildren_mjo__c> deleteJo =  new List<ProgressNote_ActionPlanChildren_mjo__c>();
                        List<ProgressNote_ActionPlanChildren_mjo__c> insertJo =  new List<ProgressNote_ActionPlanChildren_mjo__c>();
                        map<Id, ProgressNote_ActionPlanChildren_mjo__c> mapOfExistingMjos = new map<Id, ProgressNote_ActionPlanChildren_mjo__c>();
                        for (ProgressNote_ActionPlanChildren_mjo__c item: [select id, Progress_Note__c, Goal__c, Objective__c
                                                                             From ProgressNote_ActionPlanChildren_mjo__c
                                                                            Where Progress_Note__c =: pn.id ]) {
                            if (item.Goal__c != null) mapOfExistingMjos.put(item.Goal__c,item);
                            else if (item.Objective__c != null) mapOfExistingMjos.put(item.Objective__c, item);
                        }
                        set<Id> idsToDelete = mapOfExistingMjos.keySet().clone();
                        if(processAssociations) idsToDelete.removeAll((list<Id>)items);
                        // items to remove - the ones not in the fancy tree
                        for(id i : idsToDelete){
                            deleteJo.add(mapOfExistingMjos.get(i));
                        }
                        // items to insert
                        set<Id> idsToInsert = processAssociations ? new set<Id>((list<Id>)items) : new set<Id>();
                        idsToInsert.removeAll(mapOfExistingMjos.keySet());
                        for(id i : idsToInsert){
                            if (i.getSObjectType().getDescribe().getName() == 'Action_Plan_Goal__c')
                               insertJo.add(new ProgressNote_ActionPlanChildren_mjo__c(Progress_Note__c = pn.id, Goal__c = i));
                            else if (i.getSObjectType().getDescribe().getName() == 'Action_Plan_Objective__c')
                               insertJo.add(new ProgressNote_ActionPlanChildren_mjo__c(Progress_Note__c = pn.id, Objective__c = i));
                        }
                        delete deleteJo;
                        insert insertJo;

                        // serialize again, this time with the known instance of shift note, that would set the note to view mode
                        DSP_Shift_Note_Basic shiftNote = new DSP_Shift_Note_Basic(pn.Id);

                        String jsonstring = json.serialize( shiftNote);
                        storeResultSTring( newreq, jsonstring );
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
                                throw(e);
                                return;
                    }
                }
                else if ( t.request_type__c == 'Disregard Shift Note') {
                    try {
                        ID pnId = t.input_params__c;
                        Progress_Note__c thePN = [select id, Purpose_Service_is_Billable__c, disregard_note__c, status__c,approval_status__c, ownerid,
                                                         Person_Being_Served__c, Person_Being_Served__r.Account.Id, No_Approval_Needed__c, Locked__c
                                                    from Progress_Note__c where id = :pnId];
                        Boolean resetLocked = thePN.Locked__c;
                        // briefly unlock to get around validation rule
                        if (resetLocked) {
                            thePN.No_Approval_Needed__c  = false;
                            thePN.Locked__c  = false;
                            update thePN;
                        }
                        thePN = [select id, Purpose_Service_is_Billable__c, disregard_note__c, status__c,approval_status__c, ownerid, Person_Being_Served__c, Person_Being_Served__r.Account.Id from Progress_Note__c where id = :thePN.Id];

                        thePN.Purpose_Service_is_Billable__c = false;
                        thePN.Disregard_Note__c = true;
                        if (resetLocked) thePN.No_Approval_Needed__c  = resetLocked;
                        update thePN;
                        // Create a task reminder that indicates who marked the Progress Note as one to "Disregard."
                        // Get the integrate account user ID to make the owner of the task.
                        User integrateUser = [ SELECT Id FROM User WHERE Username LIKE 'integration%' LIMIT 1];
                        Id integrateUserId = integrateUser.Id;
                        DateTime n = DateTime.now();
                        insert (new Task(Subject = 'Disregard', Status = 'Completed', Priority = 'Normal', OwnerId = integrateUserId, Description = 'Note disregarded by ' + UserInfo.getName() + ', ' + n.format('MM/dd/yyyy hh:mm a'), WhoId = thePN.Person_Being_Served__c, WhatId = thePN.Id, ActivityDate = n.date()));

                        // serialize again, this time with the known instance of shift note, that would set the note to view mode
                        DSP_Shift_Note_Basic shiftNote = new DSP_Shift_Note_Basic(pnId);

                        String jsonstring = json.serialize( shiftNote);
                        storeResultSTring( newreq, jsonstring );
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
                                throw(e);
                                return;
                    }
                }
                else if ( t.request_type__c == 'TimeLog') {
                    try {
                        ID saId = (ID) t.input_params__c;
                        DSP_TimeLogListing timeLog = new DSP_TimeLogListing(saId);
                        String jsonstring = json.serialize(timeLog);
                        storeResultSTring(newreq, jsonstring);
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
                                throw(e);
                                return;
                    }
                }
                else if ( t.request_type__c == 'Incident') {
                    try {
                        String inputs = t.input_params__c;
                        Im_Report_Incident incident = new Im_Report_Incident(inputs);
                        String jsonstring = json.serialize(incident);
                        storeResultSTring(newreq, jsonstring );
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
                                throw(e);
                                return;
                    }
                }
                else if ( t.request_type__c == 'Update Incident') {
                    try {
                        Map<String, String> inputs = (Map<string, string>) json.deserialize(t.input_params__c, Map<String, String>.class);
                        // upsert the incident
                        Im_Incident__c event = (Im_Incident__c) json.deserialize(inputs.get('payload.event'), Im_Incident__c.class);
                        upsert(event);
                        Im_Report_Incident incident = new Im_Report_Incident(event.id);
                        String jsonstring = json.serialize(incident);
                        storeResultSTring(newreq, jsonstring);
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
                                throw(e);
                                return;
                    }
                }
                else if ( t.request_type__c == 'Insert-Im_InvolvedParty') {
                    try {
                        // upsert the incident
                        Im_InvolvedParty__c invPrty = (Im_InvolvedParty__c) json.deserialize(t.input_params__c, Im_InvolvedParty__c.class);
                        upsert(invPrty);
                        String jsonstring = json.serialize(MyRemoteMethods.getInvolvedParty(String.valueOf(invPrty.id)));
                        storeResultSTring(newreq, jsonstring);
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
                                throw(e);
                                return;
                    }
                }
                else if ( t.request_type__c == 'Delete-Im_InvolvedParty') {
                    try {
						if (!(t.input_params__c instanceof Id)) throw new CustomException('ERROR: Deleting involved party. Please contact the Implementation Team at Implementation@thementornetwork.com or the IT Service Center at 888-774-4872.');
						//delete the eval values, annotations and then the Involved party
                    	delete [select id from Eval_Value__c where What_ID_Object__c = 'Im_InvolvedParty__c' and What_ID__c =: t.input_params__c];
                    	delete [select id from Evaluation_Response__c where ImInvolvedPartyAnnotations__c =: t.input_params__c and RecordType.Name = 'Annotation'];
                    	delete [select id from Im_InvolvedParty__c where id =: t.input_params__c];
	                    newreq.fulfilled__c = true;
	                    newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
                                throw(e);
                                return;
                    }
                }
                else if ( t.request_type__c == 'Delete-InvPrtyEvntTyp') {
                    try {
                    	map<String, object> inputs = (Map<string, object>) json.deserializeUntyped(t.input_params__c);
                        String sectionIdentifier = (String) inputs.get('sectionIdentifier');
                        String invPrty = (String) inputs.get('invParty');
                        delete [select id from Eval_Value__c where eval_Section_Id__c =: sectionIdentifier and What_ID_Object__c = 'Im_InvolvedParty__c' and What_ID__c =: invPrty];
                        delete [select id from Evaluation_Response__c where ImInvolvedPartyAnnotations__c =: invPrty and RecordType.Name = 'Annotation' and EvalValueSectionIdentifier__c =: sectionIdentifier];

                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
                                throw(e);
                                return;
                    }
                }
                else if ( t.request_type__c == 'Get-InvolvedPartyEventTypes') {
                    try {
                        map<String, object> inputs = (Map<string, object>) json.deserializeUntyped(t.input_params__c);
                        Id invPrty = (Id) inputs.get('involvedParty');
                        String invPrtyTyp = (String) inputs.get('involvedPartyType');

                        TMN_TreePktDocTable formTree = IncidentInvolvedPartyModel.getInvolvedPartyTypes(
                            new String[] { 'Involved Party' },
                            invPrtyTyp,
                            invPrty
                        );
                        newreq.return_value__c = JSON.serialize(formTree.root.children);
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
                                throw(e);
                                return;
                    }
                }
                else if ( t.request_type__c == 'Insert-InvolvedPartyEvtTyps') {
                    try {
                        map<String, object> inputs = (Map<string, object>) json.deserializeUntyped(t.input_params__c);
                        set<String> evalSections = new set<String>();
                        list<object> evalSecO = (List<object>) inputs.get('eventsAdded');
                        for (Object o : evalSecO){
                            evalSections.add((String)o);
                        }
                        IncidentInvolvedPartyModel.insertInvolvedPartyTypes(evalSections, (Id) inputs.get('involvedParty'));
	                      newreq.return_value__c = '';
	                      newreq.fulfilled__c = true;
	                      newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
                        newreq.fulfilled__c = false;
                        newreq.return_value__c = json.serialize( e.getMessage() );
                        throw(e);
                        return;
                    }
                }


			// update the request back to the user
			update newreq;
			}
	}

	public void storeResultString( transaction_queue__c req, String longstring) {


			String[] parts = new String[0];
			system.debug('STRING IS ' + longstring.length());
			Integer lastEnd = 0;
			integer totalAdd = 0;
			String substr;

			while ( totalAdd < longstring.length()) {

				system.debug('TOTALADD' + totalAdd );
				substr = longstring.substring( totaladd, totaladd + Math.Min( 131072, longstring.length() - totalAdd));
				system.debug( substr.length());
				parts.add( substr );
				totalAdd += substr.length();

			}
			system.debug('THE STRING BROKEN UP:' + parts.size());

			// need to protect leading and trailing spaces!
			if ( parts.size() > 0 )
				req.return_value__c = ProtectLeadingBlank(parts[0]);
			if (parts.size() > 1 )
				req.return_value_2__c = ProtectLeadingBlank(parts[1]);
			if ( parts.size() > 2 )
				req.return_value_3__c = ProtectLeadingBlank(parts[2]);
			if ( parts.size() > 3 )
				req.return_value_4__c = ProtectLeadingBlank(parts[3]);
			if ( parts.size() > 4 )
				req.return_value_5__c = ProtectLeadingBlank(parts[4]);
			if ( parts.size() > 5 )
				req.return_value_6__c = ProtectLeadingBlank(parts[5]);
			if ( parts.size() > 6 )
				req.return_value_7__c = ProtectLeadingBlank(parts[6]);
		}

		string ProtectLeadingBlank( string inputstr) {

			// protect both leading and trailing
			String myChar = String.fromCharArray( new List<integer> { 206 } );
			String newstr = inputstr;

			// leading blank
			if ( inputstr.startsWith(' ')) {
				newstr = myChar + newstr.removeStart(' ');
			}

			// trailing blank
			if ( inputstr.endsWith(' ')) {
				newstr = newstr.removeEnd(' ') + myChar;
			}

			return newstr;
		}
	class CustomException extends Exception {}

}