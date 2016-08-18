public with sharing class CaseMgmtNoteApprovalReportExt {
	
	public date startDate {get; set;}
    public date endDate {get; set;}
    public list<Progress_Note__c> rptData {get; set;}
    public list<Progress_Note__c> selectedPns = new list<Progress_Note__c>();
    public list<Progress_Note__c> finalNotes {get; set;}
    public list<ProcessInstanceWorkitem> approvalData {get; set;}
    public Service_Assignment__c saData {get; set;}
    public String actionString {get; set;}
    public ID LoggedinuserID{get;set;}
    Set<ID> approvalID = new Set<ID>();
    public Progress_Note__c thePN {get; set;}
   	//List<Approval.ProcessWorkitemRequest> approvalProcessing = new List<Approval.ProcessWorkitemRequest>();
    public CaseMgmtNoteApprovalReportExt() {
    	ApexPages.getMessages().clear();
    	actionString = '';
        thePN = new Progress_Note__c();
        approvalData = [SELECT Id,ProcessInstanceId,CreatedDate,ActorId,CreatedById,CreatedBy.Name,ProcessInstance.LastModifiedBy.Name,
    	 					ProcessInstance.TargetObject.Name,ProcessInstance.LastModifiedById,ProcessInstance.TargetObjectId 
    	 					FROM ProcessInstanceWorkitem WHERE ActorId=:UserInfo.getUserId() order by CreatedDate desc limit 1000];
        
        for(ProcessInstanceWorkitem p: approvalData){
        	approvalID.add(p.ProcessInstance.TargetObjectId);
        }
        
		rptData = [SELECT Id, Start_Time__c, Type_of_Contact__c,Narrative__c,CM_Billable_Category__c,
						CreatedBy.Name, CreatedDate, Name, Program_Code__c, Service_Assignment__r.Service_Location__r.Location_Nickname__c,
						Topic_Other__c
					FROM Progress_Note__c
					WHERE 
						RecordType.DeveloperName = 'RW_Case_Management' AND
						ID =: approvalID
					];
				system.debug('constructor' +actionString);
    }
    public pagereference approvalAction(){
    	for(Progress_Note__c p: rptData){
    		if(p.Topic_Other__c == true){
    			selectedPns.add(p);
    		}
    	}
    	Set<Id> pIds = (new Map<Id, ProcessInstance>([SELECT Id,Status,TargetObjectId FROM ProcessInstance where Status='Pending' and TargetObjectId in :selectedPns])).keySet();
		Set<Id> pInstanceWorkitems = (new Map<Id, ProcessInstanceWorkitem>([SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId in :pIds])).keySet();
	    for(ID pApproRej: pInstanceWorkitems){
	    	Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
	        req.setComments(thePN.Approval_Comment__c);
	        req.setAction(actionString);
	        if(actionString == 'Approve'){
	        	 req.setNextApproverIds(new Id[] {thePN.Approval_User__c});
	        }
	        req.setWorkitemId(pApproRej);
	     	//approvalProcessing.add(req);   
	     	Approval.ProcessResult result =  Approval.process(req);
	    }  
    //Approval.ProcessResult[] result =  Approval.process(approvalProcessing);
     	pagereference pageref = new Pagereference('/apex/rptCase_Management_Note_Approval_Report');
        pageref.setredirect(true);
        return pageref;
    }
    public pagereference reassign(){
 		for(Progress_Note__c p: rptData){
    		if(p.Topic_Other__c == true){
    			selectedPns.add(p);
    		}
    	}
		List<ProcessInstanceWorkItem> workItemList = [Select p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId,p.ProcessInstanceId,p.OriginalActorId,p.Id,p.ActorId
		        From ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId = :  selectedPns];
		for(ProcessInstanceWorkitem pReassign: workItemList){
			pReassign.ActorId  = thePN.Approval_User__c; 
		}
		
		update workItemList;
		pagereference pageref = new Pagereference('/apex/rptCase_Management_Note_Approval_Report');
        pageref.setredirect(true);
        return pageref;
 
	}
    
}