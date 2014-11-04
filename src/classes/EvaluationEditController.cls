public with sharing class EvaluationEditController{
    public Evaluation__c evaluation { get; set; }
    public ApexPages.standardController stdController;

    public EvaluationEditController(ApexPages.standardController stdController) {
        this.stdController = stdController;
        evaluation = (Evaluation__c) stdController.getRecord();
    }

    public PageReference redirect() {
        PageReference returnURL;
        if(evaluation.RecordTypeId == Utility.getEvaluationRecordType('NursesAssessment')) {
            returnURL = new PageReference('/apex/NursingEvaluationEdit?id='+evaluation.id);
        } else if (evaluation.RecordTypeId == Utility.getEvaluationRecordType('NeuroRestorative')) {
            returnURL = new PageReference('/apex/NeuroEvaluationEdit?id='+evaluation.id);
        } else if (evaluation.RecordTypeId == Utility.getEvaluationRecordType('CareMeridian')) {
            returnURL = new PageReference('/apex/CareMeridianEvaluationEdit?id='+evaluation.id);
        }
        return returnURL;
    }
}