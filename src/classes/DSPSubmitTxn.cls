public with sharing class DSPSubmitTxn {
public TxnQueueResponseController controller;
public string ackAPID { get; set;}
public string initials { get; set; }
public string requestType { get; set; }
public string inputArgs { get; set; }

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
    
    Boolean err = false;
	for(DSP_WeeklySkillTracking.DSPObjectiveWrapper objectivewrp: controller.SkillResponse.objectivesmap){
             for(Date day: objectivewrp.ResultsMap.keyset()){
                 DSP_WeeklySkillTracking.ASRWrapper result = objectivewrp.ResultsMap.get(day);
                 if (result.Attempts != 0 ||
                     result.status != null ||
                     result.Met != null ||
                     !String.IsEmpty(result.Initials) ) {

                     // Enforce the Validation rules.  Deactivating the controls means the values not sent from client
                     // So have to do it here.
                        if (result.status == 'L' ||
                            result.status == 'H' ||
                            result.status == 'S' ||
                            result.status == 'HL' ) {
                            result.Met = null;
                            result.Attempts = null;
                        }
                        if (result.status == 'D' ) {
                            result.Met = 'N';
                        }
	                    if ( result.status == 'I' || 
                        	 result.status == 'V' ||
                        	 result.status == 'P' ||
                        	 result.status == 'FP' ||
                        	 result.status == 'M' ||
                        	 result.status == 'PP' ||
                        	 result.status == 'D') {
							if ( result.attempts == null  ) {
								ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result.day.format() + ': Attempts required for prompt/status' + result.status));	
								err = true;	
							}
							if ( result.met == null ) {
								ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result.day.format() + ': Met objective required for prompt/status ' + result.status));
								err = true;
							}
                        } else {
                        
                        	if ( result.status == null ) {
								ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result.day.format() + ': Please enter a prompt/status'));
								err = true;
							}
                       	}                        

						if ( String.IsEmpty(result.initials)) {
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result.day.format() + ': Please enter your initials ' ));
							err = true;
						}
						
						
    					if ( err) 
    						return null;
    					else                    
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


private Map<String,String> requestToPage = new Map<String, String> { 'Action Plan' => '/apex/DSPActionPlan', 
                                                                         'Person Being Served' => '/apex/DSPPersonBeingServedView',
                                                                         'Seizures' => '/apex/DSP_PbsSeizureListing',
                                                                         'Risk' => '/apex/DSP_Assessment_RiskForm',
                                                                         'ISSA' => '/apex/DSP_Assessment_ISSAForm',
                                                                         'BehaviorList' => '/apex/DSPWorksheets#Behavior',  // list of worksheets
                                                                         'SkillList' => '/apex/DSPWorksheets#Skill',    // list of worksheets
                                                                         'Behavior' => '/apex/DSPBehaviorTracking',
                                                                         'Skill' => '/apex/DSPWeeklySkillTracking'
                                                                         };
public pageReference submitTxnRequest() {
        // submit a transaction queue request 
        // redirect to the correct page with the transaction queue id
        //system.debug('inside submitrequest:' + requestType + ', ' + inputArgs);
        
        // get out if the action type is not understood
        if ( !requestToPage.keyset().contains( requestType )) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unknown action type: ' + requestType));
            return null;
        }
        Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
        txn.request_type__c = requestType;
        txn.requested_date_time__c = DateTime.Now();
        txn.input_params__c = inputArgs;
        
        try { 
            insert txn;
            PageReference pr =  new PageReference( requestToPage.get( requestType ));
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