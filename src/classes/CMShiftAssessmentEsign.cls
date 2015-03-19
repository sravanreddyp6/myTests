public with sharing class CMShiftAssessmentEsign implements AuthenticatedAction {
    public PageReference handle(Id recordId, Id userId) {
        Evaluation_Response__c currentResponse = new Evaluation_Response__c();
        currentResponse.RecordTypeId = Utility.getEvaluationResponseRecordType('E-Signature');
        currentResponse.Evaluation__c = recordId;
        insert currentResponse;
        Evaluation__c assessment = new Evaluation__c(
            Id = recordId,
            Is_Being_Signed__c = true,
            Status__c = EvalDynamicExt.determineEvalStatus(recordId)
        );
        update assessment;
        return null;
    }
}