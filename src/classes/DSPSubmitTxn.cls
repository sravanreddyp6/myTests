public with sharing class DSPSubmitTxn {
public TxnQueueResponseController controller;
public string ackAPID { get; set;}
public string initials { get; set; }

public DSPSubmitTxn (TxnQueueResponseController controller) {
	this.controller = controller;
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
	
public pageReference ackAssessment() {
        PageReference pr;
        Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
        txn.requested_date_time__c = DateTime.Now();
        txn.input_params__c = controller.thisTxn.input_params__c;
        txn.request_type__c = 'Acknowledge Assessment';
        
        try { 
            insert txn;
            pr =  ApexPages.currentPage().getUrl().containsIgnoreCase('DSP_Assessment_RiskForm') ? Page.DSP_Assessment_RiskForm : Page.DSP_Assessment_IssaForm;
            pr.getParameters().put('txnID', txn.ID);
            pr.setRedirect(true);
            return pr;
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
}

public pageReference saveSkillResults ( ) {
	
	List <DSP_WeeklySkillTracking.ASRWrapper> toupdate = new List<DSP_WeeklySkillTracking.ASRWrapper>();
    
	for(DSP_WeeklySkillTracking.DSPObjectiveWrapper objectivewrp: controller.SkillResponse.objectivesmap){
             for(Date day: objectivewrp.ResultsMap.keyset()){
                 DSP_WeeklySkillTracking.ASRWrapper result = objectivewrp.ResultsMap.get(day);
                 if (result.Attempts != 0 ||
                     result.status != null ||
                     result.Met != null ||
                     !String.IsEmpty(result.Initials) ) {

                     // Enforce the Validation rules.  Deactivating the controls means the values not sent from client
                     // So have to do it here.
                        if (result.status == 'A' ||
                            result.status == 'H' ||
                            result.status == 'S' ||
                            result.status == 'HL' ) {
                            result.Met = null;
                            result.Attempts = null;
                        }
                        if (result.status == 'D' ) {
                            result.Met = 'N';
                        }
                        toupdate.Add( result );
                     
                 }
             }
         }
 	
        try {
        	Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
			txn.request_type__c = 'Update Skill';
			txn.requested_date_time__c = DateTime.Now();
			Map<String, String> inputs = new Map<String, String	>{ 'Action_plan_worksheet__c' => string.valueOf(controller.skillResponse.wsId), 'action_skill_results' => json.serialize(toUpdate)}; 
		
			txn.input_params__c = json.serialize( inputs);
		
			try { 
				insert txn;
				PageReference pr =  Page.DSPWeeklySkillTracking;
				pr.getParameters().put('txnID', txn.ID);
				pr.setRedirect(true);
				return pr;
			}
			catch (Exception e) {
				throw(e);
			}	
        }  catch ( Exception e) {
        	throw(e);
        }
        
        return null;
    }

	
	

}