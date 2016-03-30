public with sharing class Evaluation_ApprovalForm {
    private ApexPages.StandardController controller;
    private Evaluation__c thisEval {get;set;}

    public Evaluation_ApprovalForm(ApexPages.StandardController controller) {
        this.controller = controller;
        thisEval = (Evaluation__c)controller.getrecord();
        getPermSets();
    }


    public boolean No_Approval_Needed {
    get {
    	
 	    // EC-317 - for resident assessment only, also check the public group in case this is a tier iii lvn
    	if (thisEval.RecordType.Name == 'NursesAssessment') {
    		return ((isTierIII || isDON ) && !inReqApprovalGroup );
    	} else {
        	return ( isTierIII || isDON );
    	}
    	}
    }
    /////////////////
    // Actions
    /////////////////

    public PageReference myFinal(){
        Evaluation__c thisEval = (Evaluation__c)controller.getrecord();
        if (thisEval.RecordType.Name == 'NursesAssessment') {
            Evaluation__c[] residentials = [
                SELECT Id FROM Evaluation__c
                 WHERE ServiceAssignment__c = :thisEval.ServiceAssignment__c
                   AND RecordType.Name = 'NursesAssessment'
                   AND Status__c LIKE 'Final%'
            ];
            if (residentials.size() == 0) {
                thisEval.Status__c = 'Final Admission';
            } else {
                thisEval.Status__c = 'Final Revision';
            }
        } else {
            thisEval.status__c = 'Final';
        }
        thisEval.Signed_At__c = system.Now();
        update thisEval;
        if ( !No_Approval_Needed) {
        	// Create an approval request for the this evaluation
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(thisEval.id);
            req1.setNextApproverIds(new Id[]{thisEval.Approver__c});
            Approval.ProcessResult result = Approval.process(req1);
        }
        return new PageReference('/' + thisEval.Id);
    }

    private boolean isDON;
    private boolean isTierIII;
    private boolean inReqApprovalGroup;
    private void getPermSets() {
    	PermissionSetAssignment[] assignments = [
                                         SELECT Id, PermissionSet.Name
                                         FROM PermissionSetAssignment
                                         WHERE AssigneeId = :UserInfo.getUserId()
                                         ];
		Set<String> permissionSets = new Set<String>();
		for (PermissionSetAssignment assignment: assignments) {
			permissionSets.add(assignment.PermissionSet.Name);
		}

		if (permissionSets.contains('iServe_DON')) {
			isDON = true;
		} else {
			isDON = false;
		}
		if (permissionSets.contains('iServe_Tier_III')) {
			isTierIII = true;
		} else {
			isTierIII = false;
		}
		
		Set<String> groupNames = new Set<String>();
   		for (GroupMember gm : [select group.name, group.DeveloperName 
                          from GroupMember 
                          where UserOrGroupId = :UserInfo.getUserId()]) {
       		groupNames.add(gm.group.DeveloperName);
   		}	    
        
        inReqApprovalGroup = groupNames.contains('CareMeridian_Req_Asmt_Approval'); 
        	                 
    }

}