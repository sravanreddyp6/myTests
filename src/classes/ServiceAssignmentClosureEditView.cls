public with sharing class ServiceAssignmentClosureEditView {

	public Id theServAssignClosureId {
		get {
			return apexpages.currentpage().getparameters().get('ServAssignCloseId');
		}	
	}
	public Id admissionId { get; set; }
	public Admission__c adm { get; set; }
	public Id pbsId { get; set; }
	public Contact pbs { get; set; }
	public Id theServAssignId { get; set; }
	Service_Assignment_Closure__c theServAssignClose = new Service_Assignment_Closure__c();
	public Boolean editMode { get; set; }
	public List<SelectOption> actionPlanGoalSelectOptions { get; set; }
	public Boolean showEdit { get; set; }
	

	public ServiceAssignmentClosureEditView(ApexPages.StandardController controller) {
		
		editMode = false;
		
		theServAssignClose = (Service_Assignment_Closure__c )controller.getRecord();
		
		if(theServAssignClosureId==null && theServAssignClose.Service_Assignment__c==null){
			editMode = true;
			theServAssignId = apexpages.currentpage().getparameters().get('ServAssignId');
			theServAssignClose.Service_Assignment__c = theServAssignId;
			theServAssignClose.Status__c = 'Open';
			admissionId = apexpages.currentpage().getparameters().get('AdmId');
			adm = [ SELECT Name FROM Admission__c WHERE Id = :admissionId LIMIT 1 ];
			if(admissionId==null) {
				admissionID = theServAssignClose.Service_Assignment__r.Admission__c;
			}
			pbsId = apexpages.currentpage().getparameters().get('PbsId');
			pbs = [ SELECT Name, OwnerId FROM Contact WHERE Id = :pbsId LIMIT 1 ];
			if(pbsId==null) {
				pbsId = theServAssignClose.Service_Assignment__r.Person_Being_Served__c;
			}
		}
		else {
			Service_Assignment_Closure__c sac = [ SELECT Service_Assignment__c, Service_Assignment__r.Admission__c, Service_Assignment__r.Admission__r.Person_Being_Served__c, Service_Assignment__r.Start_Date__c FROM Service_Assignment_Closure__c WHERE Id = :theServAssignClose.Id LIMIT 1 ];
			theServAssignId = theServAssignClose.Service_Assignment__c;
			pbs = [ SELECT Name, OwnerId FROM Contact WHERE Id = :sac.Service_Assignment__r.Admission__r.Person_Being_Served__c LIMIT 1 ];
			pbsId = pbs.Id;
			adm = [ SELECT Name FROM Admission__c WHERE Id = :sac.Service_Assignment__r.Admission__c LIMIT 1 ];
			admissionId = adm.Id;
		}
		
		// There should only be one action plan per the assumptions in place as of development around CTEAE-125 & 126.  J. Gilliam, 
		List<AggregateResult> actionPlanArs = [ SELECT Id, MAX(CreatedDate) max FROM Action_Plan__c WHERE Service_Assignment__c = :theServAssignId AND Status__c = 'Active Final' GROUP BY Id LIMIT 1 ];
		System.debug('actionPlanArs: ' + actionPlanArs);
	
		actionPlanGoalSelectOptions = new List<SelectOption>();
		actionPlanGoalSelectOptions.add(new SelectOption('--None--','--None--'));	
		
		if(actionPlanArs.size()>0) {
			Object actionPlanIdObj = actionPlanArs[0].get('Id');
			Id actionPlanId = (Id)actionPlanIdObj;
			
			//Action_Plan__c actionPlan = [ SELECT Id FROM Action_Plan__c WHERE Service_Assignment__c = :theServAssignId AND Status__c = 'Active Final' LIMIT 1 ];
			
			List<Action_Plan_Goal__c> actionPlanGoals = [ SELECT Description__c FROM Action_Plan_Goal__c WHERE Action_Plan__c = :actionPlanId ];
			
			integer maxLen;
			for(Action_Plan_Goal__c apg : actionPlanGoals) {
				maxLen = Math.min(apg.Description__c.Length(), 255);
				actionPlanGoalSelectOptions.add(new SelectOption(apg.Description__c.substring(0, maxLen), apg.Description__c.substring(0, maxLen)));
			}
		}
		
			
	}

// START:  Method for displaying error / message text in the message take on VF page.
    private void addError(String msg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, msg));
    }
// END:  Method for displaying error / message text in the message take on VF page.
	
	public PageReference save() {
		
		Savepoint servAssignCloseSaveSp = Database.setSavepoint();
		
		try {
			if(theServAssignClose.Primary_Treatment_Goal__c=='--None--') {
				theServAssignClose.Primary_Treatment_Goal__c = null;
			}
			
			if(theServAssignClose.Discharge_Type__c=='Final Discharge') {
				theServAssignClose.Date_of_Final_FCT_Meeting__c=null;
			}
			if(theServAssignClose.Discharge_Type__c=='Step-Down from FCT to other IFCS service') {
				theServAssignClose.Final_Discharge_Date__c=null;	
			}
			
			if(theServAssignClose.Placement_Status_at_Discharge__c=='Maintained Family Placement') {
				theServAssignClose.Was_Out_of_Home_Placement_Planned__c=null;
			}
			if(theServAssignClose.Placement_Status_at_Discharge__c=='Reunified with Family' || theServAssignClose.Placement_Status_at_Discharge__c=='Self care/Planned independent living'
				|| theServAssignClose.Placement_Status_at_Discharge__c=='Maintained out-of-home placement') {
					theServAssignClose.Home_Placement_Recent_but_Prior__c=null;
					theServAssignClose.Was_Out_of_Home_Placement_Planned__c=null;
			}
			if(theServAssignClose.Placement_Status_at_Discharge__c=='Placed out-of-home') {
				theServAssignClose.Home_Placement_Recent_but_Prior__c=null;
			}
			
			if(theServAssignClose.Aftercare_Plan_Services__c=='Discharge from IFCS: Family will request support if they should need or desire it'
				|| theServAssignClose.Aftercare_Plan_Services__c=='--None--' || theServAssignClose.Aftercare_Plan_Services__c==null) {
				theServAssignClose.Specify_agency_service__c=null;
				theServAssignClose.Continuing_Service_Delivery_Model_s__c=null;
				theServAssignClose.Compared_to_FCT_aftercare_services_are__c=null;
			}
						
			upsert theServAssignClose;
			editMode = false;
			return null;
		}
		catch(Exception e) {
	        addError(e.getMessage());
	        Database.rollback(servAssignCloseSaveSp);
	        return null;				
		}
		
	}
	
	public PageReference editSac() {
		if(theServAssignClose.Status__c=='Locked') {
			addError('This Service Assignment Closure has been approved and is locked for editing.  Please contact a system administrator if you need the Service Assignment Closure to be unlocked.');
			return null;
		}
		else if(theServAssignClose.Status__c=='Pending Approval') {
			addError('This Service Assignment Closure has been submitted for approval and is locked for editing.  Please contact a system administrator if you need the Service Assignment Closure to be unlocked.');
			return null;
		}
		else {
			editMode = true;
			return null;
		}
	}

	public PageReference cancel() {
		
		editMode = false;
		return null;
		
	}
	
	public PageReference submit() {
		
		Boolean errorsExist = false;
		
		List<Assessment__c> fadsForThisServAssign = [select Name, Phase__c, Status__c, Disregard__c from Assessment__c where Type__c = 'FAD Summary' AND Service_Assignment__c = :theServAssignId AND Status__c = 'Locked' AND Disregard__c = false ];
		Boolean initialFadPresent = false;
		Boolean month3FadPresent = false;
		Boolean finalFadPresent = false;
		Boolean missingAFad = true;
		
		for(Assessment__c a : fadsForThisServAssign) {
			if(a.Phase__c=='Initial') {
				initialFadPresent=true;
			}
			if(a.Phase__c=='3 Month') {
				month3FadPresent = true;
			}
			if(a.Phase__c=='Final') {
				finalFadPresent = true;
			}
			if(initialFadPresent && month3FadPresent && finalFadPresent) {
				missingAFad = false;
			}
		}
		
		if(theServAssignClose.Status__c=='Locked') {
			addError('This Service Assignment Closure has been approved and is locked for editing, and cannot be approved again.  Please contact a system administrator if you need the Service Assignment Closure to be unlocked.');
			return null;
		}
		else if(theServAssignClose.Status__c=='Pending Approval') {
			addError('This Service Assignment Closure has been submitted for approval and is locked for editing, and cannot be submitted for approval again unless it is first rejected by the approver.  Please contact the approver or a system administrator if you need the Service Assignment Closure to be unlocked.');
			return null;
		}
		else {
			try {
				if(theServAssignClose.Discharge_Type__c==null) {
					addError('You must set a value for "Final or Step-Down from FCT to other IFCS service" before approval of the Service Assignment Closure.');
					errorsExist = true;
				}
				if(theServAssignClose.Placement_Status_at_Discharge__c==null) {
					addError('You must set a value for "Placement Status at Discharge" before approval of the Service Assignment Closure.');
					errorsExist = true;
				}	
				if(theServAssignClose.Reason_for_Discharge__c==null) {
					addError('You must set a value for "Reason for Discharge" before approval of the Service Assignment Closure.');
					errorsExist = true;
				}		
				if(theServAssignClose.Primary_Treatment_Goal__c==null) {
					addError('You must set a value for "Primary Treatment Goal" before approval of the Service Assignment Closure.');
					errorsExist = true;
				}	
				if(theServAssignClose.FCS_Staff_Report__c==null) {
					addError('You must set a value for "FCS (Staff) Report" before approval of the Service Assignment Closure.');
					errorsExist = true;
				}	
				if(theServAssignClose.Family_Individual_Report__c==null) {
					addError('You must set a value for "Family/Individual Report" before approval of the Service Assignment Closure.');
					errorsExist = true;
				}	
				if(theServAssignClose.Family_Individual_Rating__c==null) {
					addError('You must set a value for "Ask the family/individual to rate their overall perception of treatment: IFCS has improved our family life (functioning)" before approval of the Service Assignment Closure.');
					errorsExist = true;
				}		
				if(theServAssignClose.Follow_up_Request_Received__c==null) {
					addError('You must set a value for "Has the family received the request for follow-up contact?" before approval of the Service Assignment Closure.');
					errorsExist = true;
				}		
				if(theServAssignClose.Aftercare_Plan_Services__c==null) {
					addError('You must set a value for "Aftercare Plan/Services" before approval of the Service Assignment Closure.');
					errorsExist = true;
				}
				if(missingAFad==true) {
					addError('Before a Service Assignment Closure can be submitted for approval, non-disregarded Initial, 3 Month, and Final FAD Assessments with a status of "Locked" must exist for the Service Assignment.  One or more of those FAD Assessments are either not present or do not meet the requirements.  Please review and update the FAD Assessments to meet the criteria, then attempt the approval submission again.');
					errorsExist = true;
				}		
				if(errorsExist) {
					return null;
				}
	            update theServAssignClose;
	            return new PageReference('/apex/ServiceAssignmentClosureApproval?ServAssignCloseId='+theServAssignClose.id);
			}
			catch(Exception e) {
				addError(e.getMessage());
				return null;
			}
		}
	}

}