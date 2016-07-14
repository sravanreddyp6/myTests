public with sharing class Notes_Plan_Approval {
    public Plan__c thePlan = new Plan__c();
    public Plan__c getThePlan (){ return thePlan;}
    public boolean planIsActive {get; set;}
    public Notes_Plan_Approval(ApexPages.StandardController controller) {
        loadData((Plan__c)controller.getRecord());
    }   
    public void loadData(Plan__c tmpPlan){
        thePlan = [select id, Approval_Status__c, Status__c, Name from Plan__c where id = :tmpPlan.id];
        planIsActive =false;
    }
    public PageReference MarkApproved(){
        try{ 
            update thePlan;       
            Plan__c tmp = [select id, Approval_Status__c, Status__c, Name from Plan__c where id = :thePlan.id];
            planIsActive = false;
            if(tmp.Status__c == 'Active')
                {planIsActive = true;
                    PageReference pageRef2 = new PageReference('/apex/Notes_Plan_Create_Audit_pdf?id='+thePlan.id); 
                    return pageRef2;            
                }
                PageReference pageRef3 = new PageReference('/'+thePlan.id); 
                return pageRef3;                  
                
        }
        catch(DMLException e){
                        thePlan.addError(e.getMessage());
                    }                     

              return null;         

    }

}