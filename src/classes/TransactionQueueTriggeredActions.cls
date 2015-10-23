// trigger code to support user inserting a row into the transaction queue
// based on the request type, the code will do the work of getting/putting the data requested with given input params
// once transaction is complete, result is serialized for return to caller with result code and fulfillment date put into queue request for audit purposes
// class is being run without sharing for full data visibility *** this can be changed by request type if necessary

public without sharing class TransactionQueueTriggeredActions {
	public void afterUpdate(List<Transaction_Queue__c> txns) {
		
			system.debug('Running as: ' + UserInfo.getUserName() );
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
						ID PBSid = t.input_params__c;
						
						// execute the transaction as requested
						Action_plan__c ap = [ select id, name, status__c, service_assignment__c from action_plan__c where service_assignment__r.admission__r.person_being_served__c = :PBSid LIMIT 1];
	                    ActionPlan_FormWithoutSharing apWithoutSharing = new ActionPlan_FormWithoutSharing(ap.id); 
	
						// serialize the result
						String jsonstring = json.serialize( apWithoutSharing );
						system.debug( 'GOT RESULT: '  + jsonstring);

	/* 
						// test that inserts PBS 					
						ID idPBStype = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName ='Person_Being_Served' and IsPersonType=true limit 1].Id;
						Account accNew = new Account( RecordTypeID = idPBStype,
	                                FirstName = 'Test',
	                                Middle_Name__pc = 'Test',
	                                LastName = 'LAST' + userinfo.getUsername(),
	                                PersonMailingSTate='Massachusetts',
	                                 PersonBirthDate = Date.newInstance(1990,09,10));					
						
						insert accNew;
	*/
						
						// update the request as having been fulfilled
						newreq.return_value__c = jsonstring;
						newreq.fulfilled__c = true;
						newreq.Date_Time_Fulfilled__c = DateTime.Now();
						
					} 
					catch (Exception e) {	
						// flag the error
						newreq.fulfilled__c = false;
						newreq.return_value__c = json.serialize( e );
					}
					
				}
				
				if ( t.request_type__c == 'Person Card' ) {
					
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
			}
			
			// update the request back to the user
			update newreq;
		
	}
}