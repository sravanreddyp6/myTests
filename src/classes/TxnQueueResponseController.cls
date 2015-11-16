public with sharing class TxnQueueResponseController {
    public Transaction_Queue__c thisTxn;
	public String TxnResponse { get; private set; }
	public ActionPlan_FormWithoutSharing  response { get; private set; }
    public DSPPersonBeingServed_WithoutSharing pbsViewResponse { get; private set; }
    public DSP_PbsSeizureListing pbsSeizureListing { get; private set; }
    public Assessment_RiskFormWithoutSharing assessmentResponse { get; private set; }
    public Assessment_IssaFormWithoutSharing assessmentIssaResponse { get; private set; }
    public DSP_Worksheets apWorksheets { get; private set; }
	
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
			thisTxn =[ select id, result_code__c, fulfilled__c, date_time_fulfilled__c, return_value__c, request_type__c, input_params__c
									from transaction_queue__c
									where id = :txnID
									and requesting_user__c = :thisUser LIMIT 1];
			
			// if there is no response, then this isn't the user who requested the data - return an error message
			if ( thisTxn == null ) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to retrieve result.'));
				return;
			}
			
			TxnResponse = thisTxn.return_value__c;
			
			if ( thisTxn.request_type__c == 'Action Plan' || thisTxn.request_type__c == 'Acknowledge Plan')
				response = (ActionPlan_FormWithoutSharing) JSON.deserialize(thisTxn.return_value__c, ActionPlan_FormWithoutSharing.class);
            else if ( thisTxn.request_type__c == 'Person Being Served')
                pbsViewResponse = (DSPPersonBeingServed_WithoutSharing) JSON.deserialize(thisTxn.return_value__c, DSPPersonBeingServed_WithoutSharing.class);
            else if ( thisTxn.request_type__c == 'Seizures' || thisTxn.request_type__c == 'Upsert Seizure')
                pbsSeizureListing = (DSP_PbsSeizureListing) JSON.deserialize(thisTxn.return_value__c, DSP_PbsSeizureListing.class);
            else if ( thisTxn.request_type__c == 'Risk')
                assessmentResponse= (Assessment_RiskFormWithoutSharing) JSON.deserialize(thisTxn.return_value__c, Assessment_RiskFormWithoutSharing.class);
            else if ( thisTxn.request_type__c == 'ISSA')
                assessmentResponse= (Assessment_RiskFormWithoutSharing) JSON.deserialize(thisTxn.return_value__c, Assessment_RiskFormWithoutSharing.class);
            else if ( thisTxn.request_type__c == 'Acknowledge Assessment'){
                String assessmentType = ApexPages.currentPage().getUrl().contains('DSP_Assessment_RiskForm') ? 'Risk' : 'ISSA';
                if (assessmentType == 'Risk') assessmentResponse = (Assessment_RiskFormWithoutSharing) JSON.deserialize(thisTxn.return_value__c, Assessment_RiskFormWithoutSharing.class);
                else assessmentIssaResponse = (Assessment_IssaFormWithoutSharing) JSON.deserialize(thisTxn.return_value__c, Assessment_IssaFormWithoutSharing.class);
            }
            else if ( thisTxn.request_type__c == 'SkillList' || thisTxn.request_type__c == 'BehaviorList') {
            	system.debug( thisTxn.return_value__c);
            	apWorksheets = (DSP_Worksheets) JSON.deserialize( thisTxn.return_value__c, DSP_Worksheets.class);
            	system.debug(apWorksheets);
            }

			system.debug(response);
		} catch (Exception e2) {
			ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to retrieve result'));
			return;
		}
	}
	
	
}