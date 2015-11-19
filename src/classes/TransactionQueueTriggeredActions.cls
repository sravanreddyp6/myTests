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
					}
					
				}
				
				else if ( t.request_type__c == 'Person Card' ) {
					
					/*
					// modify an account - testing
					// get the pbs id from the request pararms
					
					Contact c = [ select id, name, middle_name__c from contact where id = :pbsid2];
					c.middle_name__c = 'Benjamin';
					update c;
					
					// serialize the result
					String jsonstring = json.serialize( c );
					system.debug( 'GOT RESULT: '  + jsonstring);
					*/

					// leverage existing controller?
					/*
					PersonRecordController prc = new PersonRecordController( );
					ID PBSid2 = t.input_params__c;
					prc.contactID = PBSid2;
					*/				
					
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
                        // update the request as having been fulfilled
                        newreq.return_value__c = jsonstring;
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
	                } catch ( Exception e ) {
	//                          newreq.return_code__c = 'ERROR';
	                            system.debug( e );
	                            newreq.fulfilled__c = false;
	                            newreq.return_value__c = json.serialize( e.getMessage() );
	                }
                }
                
                else if ( t.request_type__c == 'Risk' ) {
                    try {
                        // get the pbs id from the request pararms
                        ID admId = t.input_params__c;
                        
                        // execute the transaction as requested
                        Assessment__c assessment = [ select id from Assessment__c where Admission__c = :admId and status__c= 'Active Final' and Assessment_Type__r.name = 'Risk' limit 1];
                        Assessment_RiskFormWithoutSharing riskAssessment = new Assessment_RiskFormWithoutSharing(assessment.id); 
    
                        // serialize the result
                        String jsonstring = json.serialize(riskAssessment);
                        //system.debug( 'GOT RESULT: '  + jsonstring);

                        // update the request as having been fulfilled
                        newreq.return_value__c = jsonstring;
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                        
                    } catch (Exception e) {   
                        // flag the error
                        newreq.fulfilled__c = false;
                        newreq.return_value__c = json.serialize( e.getMessage() );
                    }
                    
                }

                else if ( t.request_type__c == 'ISSA' ) {
                    try {
                        // get the pbs id from the request pararms
                        ID admId = t.input_params__c;
                        
                        // execute the transaction as requested
                        Assessment__c assessment = [select id from Assessment__c where Admission__c = :admId and status__c= 'Active Final' and Type__c = 'ISSA' limit 1];
                        Assessment_IssaFormWithoutSharing issaAssessment = new Assessment_IssaFormWithoutSharing(assessment.id); 
    
                        // serialize the result
                        String jsonstring = json.serialize(issaAssessment);
                        //system.debug( 'GOT RESULT: '  + jsonstring);

						// break up the string if necessary
						storeResultString( newreq, jsonstring );


                        // update the request as having been fulfilled
                        newreq.return_value__c = jsonstring;
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                        
                    } catch (Exception e) {   
                        // flag the error
                        newreq.fulfilled__c = false;
                        newreq.return_value__c = json.serialize( e.getMessage() );
                    }
                    
                }

                else if ( t.request_type__c == 'Acknowledge Assessment') {
                    try {
                        // get the pbs id from the request pararms
                        ID admId = t.input_params__c;
                        Assessment__c assessment;
                        DSP_AssessmentResponseType assessmentDetails;
                        String assessmentType = ApexPages.currentPage().getUrl().containsIgnoreCase('DSP_Assessment_RiskForm') ? 'Risk' : 'ISSA';
                        if (assessmentType == 'Risk') assessment = [ select id from Assessment__c where Admission__c = :admId and status__c= 'Active Final' and Assessment_Type__r.name = 'Risk' limit 1];
                        else  assessment = [ select id from Assessment__c where Admission__c = :admId and status__c= 'Active Final' and Type__c = 'ISSA' limit 1];
                        Acknowledgment__c confirmRec = new Acknowledgment__c(Assessment__c = assessment.id, User__c = UserInfo.getUserId());
                        insert confirmRec;
                        
                        if (assessmentType == 'Risk') assessmentDetails = new Assessment_RiskFormWithoutSharing(assessment.id);
                        else assessmentDetails = new Assessment_IssaFormWithoutSharing(assessment.id);
 
                        // serialize the result
                        String jsonstring = json.serialize( assessmentDetails );
                        // update the request as having been fulfilled
                        newreq.return_value__c = jsonstring;
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
//                          newreq.return_code__c = 'ERROR';
                            system.debug( e );
                            newreq.fulfilled__c = false;
                            newreq.return_value__c = json.serialize( e.getMessage() );
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
                        // update the request as having been fulfilled
                        newreq.return_value__c = jsonstring;
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
    //                          newreq.return_code__c = 'ERROR';
                                system.debug( e );
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
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
                            // update the request as having been fulfilled
                            newreq.return_value__c = jsonstring;
                            newreq.fulfilled__c = true;
                            newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
//                          newreq.return_code__c = 'ERROR';
                            system.debug( e );
                            newreq.fulfilled__c = false;
                            newreq.return_value__c = json.serialize( e.getMessage() );
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
	
							// update the request as having been fulfilled
							newreq.return_value__c = jsonstring;
							newreq.fulfilled__c = true;
							newreq.Date_Time_Fulfilled__c = DateTime.Now();
							
							
					} catch ( Exception e ) {
//							newreq.return_code__c = 'ERROR';
							system.debug( e );
							newreq.fulfilled__c = false;
							newreq.return_value__c = json.serialize( e.getMessage() );
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
                        // update the request as having been fulfilled
                        newreq.return_value__c = jsonstring;
                        newreq.fulfilled__c = true;
                        newreq.Date_Time_Fulfilled__c = DateTime.Now();
                    } catch ( Exception e ) {
    //                          newreq.return_code__c = 'ERROR';
                                system.debug( e );
                                newreq.fulfilled__c = false;
                                newreq.return_value__c = json.serialize( e.getMessage() );
                    }
                }
                
			
			// update the request back to the user
			update newreq;
			}
	}
	
	void storeResultString( transaction_queue__c req, String longstring) {
		
			Pattern p = Pattern.compile('(.{1,131072})+');
			Matcher m = p.matcher(longstring);
			String[] parts = new String[0];
			while(m.find()) {
				parts.add(m.group(0));
			}
			
			system.debug('THE STRING BROKEN UP:' + parts);
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
	}
}