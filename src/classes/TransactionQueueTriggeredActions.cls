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
                		ID inputID = t.input_params__c;
                		ID wksheetID;
                		
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
                			
                		DSP_BehaviorTracking wksht = new DSP_BehaviorTracking( wksheetid, null );
                		
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
			
			// update the request back to the user
			update newreq;
			}
	}
	
	void storeResultString( transaction_queue__c req, String longstring) {
		

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
			if ( parts.size() > 0 )
				req.return_value__c = parts[0];
			if (parts.size() > 1 )
				req.return_value_2__c = parts[1];
			if ( parts.size() > 2 )
				req.return_value_3__c = parts[2];
			if ( parts.size() > 3 )
				req.return_value_4__c = parts[3];
			if ( parts.size() > 4 )
				req.return_value_5__c = parts[4];
			if ( parts.size() > 5 )
				req.return_value_6__c = parts[5];
			if ( parts.size() > 6 )
				req.return_value_7__c = parts[6];
		}

}