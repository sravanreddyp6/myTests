public with sharing class EvaluationResponseTable_Esign implements AuthenticatedAction{
    
    public PageReference handle(Id recordId, Id userId) {
        
        Evaluation_Response__c rec = new Evaluation_Response__c(
            Id = recordId,
            eSigned_By__c = userId,
            eSigned_On__c = system.today()
        );
        update rec;
        return null;
    }   
    public EvaluationResponseTable_Esign() {
        
    }
}