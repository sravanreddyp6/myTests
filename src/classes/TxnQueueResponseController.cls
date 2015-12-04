public with sharing class TxnQueueResponseController {
    public Transaction_Queue__c thisTxn;
	public String TxnResponse { get; private set; }
	public String TxnRequestType { get { return thisTxn.request_type__c;} }
	public String TxnInputParams { get { return thisTxn.input_params__c;} }
	public ActionPlan_FormWithoutSharing  response { get; private set; }
    public DSPPersonBeingServed_WithoutSharing pbsViewResponse { get; private set; }
    public DSP_PbsSeizureListing pbsSeizureListing { get; private set; }
    public Assessment_RiskFormWithoutSharing assessmentResponse { get; private set; }
    public Assessment_IssaFormWithoutSharing assessmentIssaResponse { get; private set; }
    public DSP_Worksheets apWorksheets { get; private set; }
    public DSP_WeeklySkillTracking skillResponse { get; private set;}
    public DSP_BehaviorTracking behaviorResponse { get; private set;}
	
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
			
			TxnResponse = thisTxn.return_value__c;
			if ( thisTxn.return_value_2__c != null )
				txnResponse += thisTxn.return_value_2__c;
			
			if ( thisTxn.return_value_3__c != null) 
				txnResponse += thisTxn.return_value_3__c;
				
			if ( thisTxn.return_value_4__c != null )
				txnResponse += thisTxn.return_value_4__c;
				
			if ( thisTxn.return_value_5__c != null )
				txnResponse += thisTxn.return_value_5__c;
			
			if ( thisTxn.return_value_6__c != null )
				txnResponse += thisTxn.return_value_6__c;
				
			if ( thisTxn.return_value_7__c != null )
				txnResponse += thisTxn.return_value_7__c;
			
			if ( thisTxn.request_type__c == 'Action Plan' || thisTxn.request_type__c == 'Acknowledge Plan')
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
            	skillResponse = (DSP_WeeklySkillTracking) JSON.deserialize ( TxnResponse, DSP_WeeklySkillTracking.class);
            }
			else if ( thisTxn.request_type__c == 'Behavior' || thisTxn.request_type__c == 'Update Behavior' ) {
				
				// LEAVE THIS IN - it's a complete hack to get by a serializing error with date class
				txnresponse = txnresponse.replace(' 00:00:00', '');

				system.debug('TO DESERIALIZE: ' + txnresponse);
            	behaviorResponse = (DSP_BehaviorTracking) JSON.deserializeStrict ( TxnResponse, DSP_BehaviorTracking.class);
            }
		} catch (Exception e2) {
			ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e2.getmessage()));
			return;
		}
	}
	
	
}