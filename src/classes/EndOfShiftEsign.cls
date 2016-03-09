public with sharing class EndOfShiftEsign implements AuthenticatedAction {
	public PageReference handle(Id recordId, Id userId) {
		String recId = String.valueOf(recordId);
		Evaluation__c assessment = [
			SELECT Id, OwnerId, Status__c, Head_to_toe_Status__c, Is_Being_Signed__c, Is_Signed__c,
			       Shift_Start_time__c, Shift_End_time__c, Recordtype.Name, ServiceAssignment__c
			  FROM Evaluation__c
			 WHERE id=: recordId
		];
		if (assessment.Recordtype.name == 'CMShiftAssessment') {
			if (assessment.Head_to_toe_Status__c == 'Draft') {
				assessment.Head_to_Toe_Status__c = 'Final';
				assessment.Head_to_Toe_Signed_At__c = System.Now();
			}
			assessment.Status__c = 'End of Shift';
			assessment.Signed_At__c = System.now();
			assessment.Signed_By__c = UserInfo.getUserId();
		} else if (assessment.RecordType.Name == 'CNA Workbook') {
			assessment.Signed_At__c = system.Now();
			assessment.Status__c = 'End of Shift';
			assessment.Signed_By__c = UserInfo.getUserId();
		}
		update assessment;

		return null;
	}
}