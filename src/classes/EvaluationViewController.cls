public with sharing class EvaluationViewController {
	public Evaluation__c evaluation { get; set; }
	public ApexPages.standardController stdController;

	public EvaluationViewController(ApexPages.standardController stdController) {
		this.stdController = stdController;
		evaluation = (Evaluation__c) stdController.getRecord();
	}

	public PageReference redirect() {
		PageReference returnURL;
		if(evaluation.RecordTypeId == Utility.getEvaluationRecordType('NursesAssessment')) {
			returnURL = new PageReference('/apex/EvalDynamic?evalId=' + evaluation.Id + '&opGrp=Care Meridian&evalType=Residential');
		} else if (evaluation.RecordTypeId == Utility.getEvaluationRecordType('NeuroRestorative')) {
			returnURL = new PageReference('/apex/NeuroEvaluationView?id='+evaluation.id);
		}else if(evaluation.RecordTypeId == Utility.getEvaluationRecordType('RestraintEvent')){
			returnURL = new PageReference('/apex/EvalDynamic?evalId=' + evaluation.Id + '&opGrp=Care Meridian&evalType=Restraint Event');
		}else if (evaluation.RecordTypeId == Utility.getEvaluationRecordType('CareMeridian')) {
			returnURL = new PageReference('/apex/CareMeridianEvaluationView?id='+evaluation.id);
		} else if(evaluation.RecordTypeId == Utility.getEvaluationRecordType('CMShiftAssessment')) {
			returnURL = new PageReference('/apex/EvalDynamic?evalId=' + evaluation.Id + '&opGrp=Care Meridian&evalType=Head to Toe');
		} else if(evaluation.RecordTypeId == Utility.getEvaluationRecordType('CNA Workbook')) {
			returnURL = new PageReference('/apex/EvalDynamic?evalId=' + evaluation.Id + '&opGrp=Care Meridian&evalType=CNA+Workbook');
		}
		return returnURL;
	}
}