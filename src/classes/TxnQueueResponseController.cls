public with sharing class TxnQueueResponseController {
    public Transaction_Queue__c thisTxn;
	public transient String TxnResponse { get; private set; }
	public String TxnRequestType { get { return thisTxn.request_type__c;} }
	public String TxnInputParams { get { return thisTxn.input_params__c;} }
	public String TxnId { get { return thisTxn.id;}}
	public ActionPlan_FormWithoutSharing  response { get; private set; }
    public DSPPersonBeingServed_WithoutSharing pbsViewResponse { get; private set; }
    public DSP_PbsSeizureListing pbsSeizureListing { get; private set; }
    public Assessment_RiskFormWithoutSharing assessmentResponse { get; private set; }
    public Assessment_IssaFormWithoutSharing assessmentIssaResponse { get; private set; }
    public DSP_Worksheets apWorksheets { get; private set; }
    public DSP_WeeklySkillTracking skillResponse { get; private set;}
    public DSP_Shift_Note_Basic shiftNote { get; private set;}
    public DSP_ShiftNoteList shiftNoteList { get; private set;}
    public DSP_BehaviorTracking behaviorResponse { get; private set;}
    public DSP_TimeLogListing timeLogListing { get; private set;}
    public Im_Report_Incident incident { get; private set;}
	
//Constructor
	public TxnQueueResponseController(){

		ID txnID;
		
		// pick up the txnid off the URL
		try {
			txnID = ApexPages.CurrentPage().getParameters().get('txnID');
		if ( txnID == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid transaction ID'));
			return;
			}
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid transaction ID'));
			return;
		}
		
		ID thisUser = UserInfo.getUserID();
		
		try {
			// get the txn result
			thisTxn =[ select id, result_code__c, fulfilled__c, date_time_fulfilled__c, 
								return_value__c, return_value_2__c, return_value_3__c, return_value_4__c, return_value_5__c, return_value_6__c, return_value_7__c,
								request_type__c, input_params__c
									from transaction_queue__c
									where id = :txnID
									and requesting_user__c = :thisUser LIMIT 1];
			
			// if there is no response, then this isn't the user who requested the data - return an error message
			if ( thisTxn == null ) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to retrieve result.'));
				return;
			}
			
			// put the protected space back into leading position if it was there before storing
			String myChar = String.fromCharArray( new List<integer> { 206 } );
			
			if ( thisTxn.return_value__c.endsWith( myChar ))
				TxnResponse = thisTxn.return_value__c.replace(mychar, ' ');
			else
				TxnResponse = thisTxn.return_value__c;
				
			if ( thisTxn.return_value_2__c != null ) {
				if (thisTxn.return_value_2__c.startsWith( myChar ) || thisTxn.return_value_2__c.endsWith( myChar ))
					txnResponse += thisTxn.return_value_2__c.replace(mychar, ' '); 
				else
					txnResponse += thisTxn.return_value_2__c;
			}
			
			if ( thisTxn.return_value_3__c != null) {
				if (thisTxn.return_value_3__c.startsWith( myChar ) || thisTxn.return_value_3__c.endsWith( myChar ))
					txnResponse += thisTxn.return_value_3__c.replace(mychar, ' '); 
				else
					txnResponse += thisTxn.return_value_3__c;
			}
			if ( thisTxn.return_value_4__c != null ) {
				if (thisTxn.return_value_4__c.startsWith( myChar ) || thisTxn.return_value_4__c.endsWith( myChar ))
					txnResponse += thisTxn.return_value_4__c.replace(mychar, ' '); 
				else
					txnResponse += thisTxn.return_value_4__c;
			}				
			if ( thisTxn.return_value_5__c != null ) {
				if (thisTxn.return_value_5__c.startsWith( myChar ) || thisTxn.return_value_5__c.endsWith( myChar ))
					txnResponse += thisTxn.return_value_5__c.replace(mychar, ' '); 
				else
					txnResponse += thisTxn.return_value_5__c;
			}			
			if ( thisTxn.return_value_6__c != null ) {
				if (thisTxn.return_value_6__c.startsWith( myChar ) || thisTxn.return_value_6__c.endsWith( myChar ))
					txnResponse += thisTxn.return_value_6__c.replace(mychar, ' '); 
				else
					txnResponse += thisTxn.return_value_6__c;
			}
			if ( thisTxn.return_value_7__c != null ) {
				if (thisTxn.return_value_7__c.startsWith( myChar ) || thisTxn.return_value_7__c.endsWith( myChar ))
					txnResponse += thisTxn.return_value_7__c.replace(mychar, ' '); 
				else
					txnResponse += thisTxn.return_value_7__c;
			}
			
			if ( thisTxn.request_type__c == 'Action Plan' || thisTxn.request_type__c == 'Acknowledge Plan' || thisTxn.request_type__c == 'Acknowledge ISP')
				response = (ActionPlan_FormWithoutSharing) JSON.deserialize(TxnResponse, ActionPlan_FormWithoutSharing.class);
            else if ( thisTxn.request_type__c == 'Person Being Served')
                pbsViewResponse = (DSPPersonBeingServed_WithoutSharing) JSON.deserialize(thisTxn.return_value__c, DSPPersonBeingServed_WithoutSharing.class);
            else if ( thisTxn.request_type__c == 'Seizures' || thisTxn.request_type__c == 'Upsert Seizure')
                pbsSeizureListing = (DSP_PbsSeizureListing) JSON.deserialize(TxnResponse, DSP_PbsSeizureListing.class);
            else if ( thisTxn.request_type__c == 'Risk')
                assessmentResponse= (Assessment_RiskFormWithoutSharing) JSON.deserialize(TxnResponse, Assessment_RiskFormWithoutSharing.class);
            else if ( thisTxn.request_type__c == 'ISSA')
                assessmentIssaResponse= (Assessment_IssaFormWithoutSharing) JSON.deserialize(TxnResponse, Assessment_IssaFormWithoutSharing.class);
            else if ( thisTxn.request_type__c == 'Acknowledge Assessment'){
                String assessmentType = ApexPages.currentPage().getUrl().containsIgnoreCase('DSP_Assessment_RiskForm') ? 'Risk' : 'ISSA';
                if (assessmentType == 'Risk') assessmentResponse = (Assessment_RiskFormWithoutSharing) JSON.deserialize(TxnResponse, Assessment_RiskFormWithoutSharing.class);
                else assessmentIssaResponse = (Assessment_IssaFormWithoutSharing) JSON.deserialize(TxnResponse, Assessment_IssaFormWithoutSharing.class);
            }
            else if ( thisTxn.request_type__c == 'SkillList' || thisTxn.request_type__c == 'BehaviorList') {
            	system.debug( thisTxn.return_value__c);
            	apWorksheets = (DSP_Worksheets) JSON.deserialize( TxnResponse, DSP_Worksheets.class);
            	system.debug(apWorksheets);
            }
            else if ( thisTxn.request_type__c == 'Skill' || thisTxn.request_type__c == 'Update Skill' ) {
				txnresponse = txnresponse.replace(' 00:00:00', '');
            	skillResponse = (DSP_WeeklySkillTracking) JSON.deserialize ( TxnResponse, DSP_WeeklySkillTracking.class);
            }
			else if ( thisTxn.request_type__c == 'Behavior' || thisTxn.request_type__c == 'Update Behavior' ) {
				
				// LEAVE THIS IN - it's a complete hack to get by a serializing error with date class
				txnresponse = txnresponse.replace(' 00:00:00', '');

				system.debug('TO DESERIALIZE: ' + txnresponse);
            	behaviorResponse = (DSP_BehaviorTracking) JSON.deserializeStrict ( TxnResponse, DSP_BehaviorTracking.class);
            }
            else if ( thisTxn.request_type__c == 'Shift Note' || thisTxn.request_type__c == 'Update Shift Note' || thisTxn.request_type__c == 'Disregard Shift Note') {
                shiftNote = (DSP_Shift_Note_Basic) JSON.deserialize ( TxnResponse, DSP_Shift_Note_Basic.class);
            }
            else if ( thisTxn.request_type__c == 'Shift Note List') {
                shiftNoteList = (DSP_ShiftNoteList) JSON.deserialize ( TxnResponse, DSP_ShiftNoteList.class);
            }
            else if ( thisTxn.request_type__c == 'Shift Note List') {
                timeLogListing = (DSP_TimeLogListing) JSON.deserialize (TxnResponse, DSP_TimeLogListing.class);
            }
            else if ( thisTxn.request_type__c == 'Incident' || thisTxn.request_type__c == 'Update Incident' || thisTxn.request_type__c == 'Disregard Incident') {
                incident = (Im_Report_Incident) JSON.deserialize (TxnResponse, Im_Report_Incident.class);
            } 

		} catch (Exception e2) {
			ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e2.getmessage()));
			return;
		}
	}
	
	
}