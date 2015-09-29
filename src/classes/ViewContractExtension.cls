public with sharing class ViewContractExtension {
    public TMN_Contract__c tmnContract {get; set;}
    public Apexpages.standardController controller; 
    
    public ViewContractExtension(ApexPages.StandardController controller) {
        this.controller = controller;
        if(!test.isRunningTest()) {
            controller.addFields(new list<string>{'Approver_1__c'});
        }
        tmnContract = (TMN_Contract__c)controller.getRecord();
        
    }
    public PageReference Submit() {
        // Create an approval request for the this evaluation
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(tmnContract.id);
        req1.setNextApproverIds(new Id[]{tmnContract.Approver_1__c});
        Approval.ProcessResult result = Approval.process(req1);
        return new PageReference('/'+tmnContract.id);   
    }
    
}