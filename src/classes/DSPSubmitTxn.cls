public with sharing class DSPSubmitTxn {
public TxnQueueResponseController controller;
public DSPHomePageController hpcontroller;
public string ackAPID { get; set;}
public string initials { get; set; }
public string requestType { get; set; }
public string inputArgs { get; set; }
public ID newtargetID { get; set; }
public boolean createNote { get; set; }


public DSPSubmitTxn (TxnQueueResponseController controller) {
	this.controller = controller;
}

public DSPSubmitTxn (DSPHomePageController controller) {
	this.hpcontroller = controller;
}
public DSPSubmitTxn (HomePageController controller) {
}
public DSPSubmitTxn(){}

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
                 system.debug('result: ' + result);
                 if (result.Attempts != null ||
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
								ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result.day.format() + ': Attempts required for prompt/status ' + result.status));	
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
                if (createNote && !err ){
                    this.requestType = 'Shift Note';
                    this.inputArgs = json.serialize(new Map<String, String>{'pbsID'=>string.valueOf(controller.skillResponse.result.Action_Plan__r.Service_Assignment__r.Admission__r.Person_Being_Served__c),
                        'saID'=>string.valueOf(controller.skillResponse.result.Action_Plan__r.Service_Assignment__c),
                        'admID'=>string.valueOf(controller.skillResponse.result.Action_Plan__r.Service_Assignment__r.Admission__c),
                        'apID'=>string.valueOf(controller.skillResponse.result.Action_Plan__c)});
                    return submitTxnRequest();
                }
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


public pageReference saveBehaviorResults ( ) {
	
		List<DSP_BehaviorTracking.ABRWrapper> toUpDate = new List<DSP_BehaviorTracking.ABRWrapper>();
		Map<id, DSP_BehaviorTracking.ABRWrapper> origData = controller.BehaviorResponse.originaldata;
		for(DSP_BehaviorTracking.Table table: controller.behaviorResponse.Tables){
			for(integer hour:table.Firstkeys){
				for(Date day : table.AllSecondKeys){
					DSP_BehaviorTracking.ABRWrapper cellObj = table.get(hour,day);
					if (cellObj == null){
						continue;
					}
					if (origData.containsKey(cellObj.Id)){
						DSP_BehaviorTracking.ABRWrapper origObj = origData.get(cellObj.Id);
						if (cellObj.occurrences != origObj.occurrences ||
							cellObj.occurred != origObj.occurred){
							toUpDate.Add(cellObj);
						}
					} else {
						if (cellObj.occurrences != null ||
							cellObj.occurred != false){
							toUpDate.Add(cellobj);
						}
					}
				}
			}
		}
		
		try {
        	Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
			txn.request_type__c = 'Update Behavior';
			txn.requested_date_time__c = DateTime.Now();
			Map<String, String> inputs = new Map<String, String	>{ 'Action_plan_worksheet__c' => string.valueOf(controller.behaviorResponse.wsId), 'behavior_results' => json.serialize(toUpdate), 'newid' => string.valueof(newtargetid) }; 
		
			txn.input_params__c = json.serialize( inputs);
		
			try { 
				insert txn;
				if (createNote){
					this.requestType = 'Shift Note';
					this.inputArgs = json.serialize(new Map<String, String>{'pbsID'=>string.valueOf(controller.behaviorResponse.result.Action_Plan__r.Service_Assignment__r.Admission__r.Person_Being_Served__c),
						'saID'=>string.valueOf(controller.behaviorResponse.result.Action_Plan__r.Service_Assignment__c),
						'admID'=>string.valueOf(controller.behaviorResponse.result.Action_Plan__r.Service_Assignment__r.Admission__c),
						'apID'=>string.valueOf(controller.behaviorResponse.result.Action_Plan__c)});
					return submitTxnRequest();
				}
				PageReference pr =  Page.DSPBehaviorTracking;
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
                                                                         'Skill' => '/apex/DSPWeeklySkillTracking',
                                                                         'Shift Note' => '/apex/DSP_ShiftNote_Basic',
                                                                         'Shift Note List' => '/apex/DSP_ShiftNoteList',
                                                                         'TimeLog' => '/apex/DSP_TimeLogListing',
                                                                         'Incident' => '/apex/ReportEvent',
                                                                         'Iowa Daily Data Summary' => '/apex/DSPIowaDailyDataSummary'
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