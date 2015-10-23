public with sharing class TxnQueueResponseController {

	public String TxnResponse { get; private set; }
	public ActionPlan_FormWithoutSharing  response { get; private set; }
	

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
		
		// get the txn result
		Transaction_Queue__c thisTxn =[ select id, result_code__c, fulfilled__c, date_time_fulfilled__c, return_value__c
								from transaction_queue__c
								where id = :txnID];
								//and requesting_user__c = :thisUser];
		
		TxnResponse = thisTxn.return_value__c;
		
		response = (ActionPlan_FormWithoutSharing) JSON.deserialize(thisTxn.return_value__c, ActionPlan_FormWithoutSharing.class);
		
		system.debug(response);
	}
	
	
}