public with sharing class EvaluationEditController{
    public Evaluation__c evaluation { get; set; }
    public ApexPages.standardController stdController;
    public Boolean isShift{get; set;}

    public EvaluationEditController(ApexPages.standardController stdController) {
        this.stdController = stdController;
        stdController.addFields(new String[]{'OwnerId','Status__c'});
        evaluation = (Evaluation__c) stdController.getRecord();
        isShift = false;
    }

    public PageReference redirect() {
        PageReference returnURL;
        if(evaluation.RecordTypeId == Utility.getEvaluationRecordType('NursesAssessment')) {
            returnURL = new PageReference('/apex/NursingEvaluationEdit?id='+evaluation.id);
        } else if (evaluation.RecordTypeId == Utility.getEvaluationRecordType('NeuroRestorative')) {
            returnURL = new PageReference('/apex/NeuroEvaluationEdit?id='+evaluation.id);
        } else if (evaluation.RecordTypeId == Utility.getEvaluationRecordType('CareMeridian')) {
            returnURL = new PageReference('/apex/CareMeridianEvaluationEdit?id='+evaluation.id);
        } else if (evaluation.RecordTypeId == Utility.getEvaluationRecordType('CMShiftAssessment')) {
        	if(evaluation.OwnerId == UserInfo.getUserId() && evaluation.Status__c == 'Draft') {
        	 returnURL = new PageReference('/apex/CMShiftAssessmentEdit?id='+evaluation.id);
        	} else if(evaluation.OwnerId != UserInfo.getUserId()){
        		isShift = true;
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only Owner ('+UserInfo.getName()+') can Edit this Assessment'));
        		return null;
        	} else if(evaluation.Status__c != 'Draft'){
        		isShift = true;
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot Edit the Assessments with status as '+evaluation.Status__c));
        		return null;
        	}
        	
        }
        return returnURL;
    }
}