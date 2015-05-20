public with sharing class Evaluation_ApprovalForm {
    private ApexPages.StandardController controller;
    private Evaluation__c thisEval {get;set;}
    
    public Evaluation_ApprovalForm(ApexPages.StandardController controller) {
        this.controller = controller;
        thisEval = (Evaluation__c)controller.getrecord();
    }


    public boolean No_Approval_Needed {
    get {
        // TO DO: is this a supervisor user?
        return false;
    }
    }
    /////////////////
    // Actions
    /////////////////
    
    public PageReference myFinal(){
        Evaluation__c thisEval = (Evaluation__c)controller.getrecord();
        thisEval.status__c = 'Final';
        update thisEval;
        if ( !No_Approval_Needed) {
            return new PageReference('/p/process/Submit?id='+controller.getid());
        }
        return new PageReference('/' + thisEval.Id);
    }
}