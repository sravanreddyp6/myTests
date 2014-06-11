public with sharing class ServiceAssignmentClosure_Approval {

	Id theServAssignClosureId = apexpages.currentpage().getparameters().get('ServAssignCloseId');
	public Service_Assignment_Closure__c theServAssignClose { get; set; }
	public Id theServAssignId { get; set; }
	public Id admId { get; set; }
	public Id pbsId { get; set; }

	public ServiceAssignmentClosure_Approval(ApexPages.StandardController controller) {
		//this.theServAssignClose = (Service_Assignment_Closure__c)controller.getRecord();
		theServAssignClose = [ SELECT No_Approval_Needed__c, Service_Assignment__c, Discharge_Type__c, Placement_Status_at_Discharge__c, Reason_for_Discharge__c,
								Primary_Treatment_Goal__c, FCS_Staff_Report__c, Family_Individual_Report__c, Family_Individual_Rating__c, Follow_up_Request_Received__c,
								Aftercare_Plan_Services__c, Service_Assignment__r.Person_Being_Served__c, Service_Assignment__r.Admission__c, Status__c 
								FROM Service_Assignment_Closure__c WHERE Id = :theServAssignClosureId ];	
	
		theServAssignId = theServAssignClose.Service_Assignment__c;
		pbsId = theServAssignClose.Service_Assignment__r.Person_Being_Served__c;
		admId = theServAssignClose.Service_Assignment__r.Admission__c;
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
				
			    if(theServAssignClose.No_Approval_Needed__c){
			    	System.debug('What is the value of theServAssignClose.No_Approval_Needed__c: ' + theServAssignClose.No_Approval_Needed__c);
	                theServAssignClose.Status__c = 'Locked';
	            	update theServAssignClose;
	            	return new PageReference('/'+theServAssignClose.id);   
	            }
	            else {
	            	update theServAssignClose;
					return new PageReference('/p/process/Submit?retURL=%2F'+theServAssignClose.Id +'&id='+theServAssignClose.id);
	            }
			}
			catch(Exception e) {
				addError(e.getMessage());
				return null;
			}
		}
	}

// START:  Method for displaying error / message text in the message take on VF page.
    private void addError(String msg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, msg));
    }
// END:  Method for displaying error / message text in the message take on VF page.

}