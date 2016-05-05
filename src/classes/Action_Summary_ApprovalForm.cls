public with sharing class Action_Summary_ApprovalForm {
    private ApexPages.StandardController controller;
    private Action_Summary__c ActionSummary {get;set;}
    
    public Action_Summary_ApprovalForm(ApexPages.StandardController controller) {
        this.controller = controller;
        ActionSummary = (Action_Summary__c)controller.getrecord();
    }


    public boolean No_Approval_Needed {
    get {
        return ActionSummary.No_Approval_Needed__c;
    }
    }
    /////////////////
    // Actions
    /////////////////
    
    public PageReference myFinal(){
        Action_Summary__c ActionSummary = (Action_Summary__c)controller.getrecord();
        ActionSummary.status__c = 'Final';
        update ActionSummary;
        if (ActionSummary.No_Approval_Needed__c == false) {
            // Create an approval request for the this evaluation
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(controller.getid());
            req1.setNextApproverIds(new Id[]{ActionSummary.Approver__c});
            Approval.ProcessResult result = Approval.process(req1);
        }
        return new PageReference('/' + ActionSummary.Id);
    }
}