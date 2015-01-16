public with sharing class CMShiftAssessmentListViewController {

	private List<Evaluation__c> evaluations;
	public Id saId {get; private set;}
	public CMShiftAssessmentListViewController() {
		if( ApexPages.currentPage().getParameters().get('saId') != null) {
			
			saId = ApexPages.currentPage().getParameters().get('saId');
			
			evaluations = [SELECT ID, Name, LastModifiedDate, Is_Signed__c,
                           Shift_Start_time__c, Shift_end_time__c, Status__c,Owner.Name,
                           (SELECT Id, CreatedDate, Owner.Name, Owner.Id
                              FROM Evaluation_Responses__r
                             WHERE RecordType.Name = 'E-Signature'
                             ORDER BY CreatedDate DESC)
                      FROM Evaluation__c
                     WHERE ServiceAssignment__c = :saId ORDER BY CreatedDate Desc];
			
		}
		
		
	}
	
	public List<Evaluation__c> getEvaluations() {
		return evaluations;
	}

}