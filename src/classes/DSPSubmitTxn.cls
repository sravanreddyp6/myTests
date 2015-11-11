public with sharing class DSPSubmitTxn {

public string ackAPID { get; set;}
public string initials { get; set; }

public DSPSubmitTxn (TxnQueueResponseController controller) {
	
}
public pageReference ackActionPlan() {
		
		// get the current actionplan ID
		// submit a transaction queue request to acknowledge
		// redirect to the action plan page with the transaction queue id
		Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
		txn.request_type__c = 'Acknowledge Plan';
		txn.requested_date_time__c = DateTime.Now();
		Map<String, String> inputs = new Map<String, String>{ 'Action_plan__c' => ackAPID, 'initials__c' => initials }; 
		
		txn.input_params__c = json.serialize( inputs);
		
		try { 
			insert txn;
			PageReference pr =  Page.DSPActionPlan;
			pr.getParameters().put('txnID', txn.ID);
			pr.setRedirect(true);
			return pr;
		}
		catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			return null;
		}
		
		
	}
	
}