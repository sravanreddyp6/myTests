public with sharing class Assess_Restraint_Esign implements AuthenticatedAction{

    public PageReference handle(Id recordId, Id userId) {
        
        Assessment__c assessment = new Assessment__c(
            Id = recordId,
            Approved_By__c = userId,
            Finalized_Date__c = system.today(),
            status__c = 'Final'
        );
        update assessment;
        return null;
    }
	
	public Assess_Restraint_Esign() {
		
	}
}