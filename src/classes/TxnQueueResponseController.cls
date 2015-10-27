public with sharing class TxnQueueResponseController {

	public String TxnResponse { get; private set; }
	public ActionPlan_FormWithoutSharing  response { get; private set; }
    public DSPPersonBeingServed_WithoutSharing pbsViewResponse { get; private set; }
	
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
			Transaction_Queue__c thisTxn =[ select id, result_code__c, fulfilled__c, date_time_fulfilled__c, return_value__c, request_type__c
									from transaction_queue__c
									where id = :txnID];
									//and requesting_user__c = :thisUser];
			
			TxnResponse = thisTxn.return_value__c;
			
			if ( thisTxn.request_type__c == 'Action Plan' || thisTxn.request_type__c == 'Acknowledge Plan')
				response = (ActionPlan_FormWithoutSharing) JSON.deserialize(thisTxn.return_value__c, ActionPlan_FormWithoutSharing.class);
            else if ( thisTxn.request_type__c == 'Person Being Served')
                pbsViewResponse = (DSPPersonBeingServed_WithoutSharing) JSON.deserialize(thisTxn.return_value__c, DSPPersonBeingServed_WithoutSharing.class);

			system.debug(response);
		} catch (Exception e2) {
			ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to retrieve result'));
			return;
		}
	}
	
	
}