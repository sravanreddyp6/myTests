public with sharing class EvaluationEditController{
    public Evaluation__c evaluation { get; set; }
    public ApexPages.standardController stdController;
    public Boolean isShift{get; set;}

    public EvaluationEditController(ApexPages.standardController stdController) {
        this.stdController = stdController;
        if(!test.isRunningTest()) {
        	stdController.addFields(new String[]{'OwnerId','Owner.Name','Status__c'});
        }
        evaluation = (Evaluation__c) stdController.getRecord();
        isShift = false;
    }

    public PageReference redirect() {
        PageReference returnURL;
        if(evaluation.RecordTypeId == Utility.getEvaluationRecordType('NursesAssessment')) {
            returnURL = new PageReference('/apex/EvalDynamic?evalId='+evaluation.Id+'&evalType=Residential&opGrp=Care+Meridian');
        } else if (evaluation.RecordTypeId == Utility.getEvaluationRecordType('NeuroRestorative')) {
            returnURL = new PageReference('/apex/NeuroEvaluationEdit?id='+evaluation.id);
        } else if (evaluation.RecordTypeId == Utility.getEvaluationRecordType('CareMeridian')) {
            returnURL = new PageReference('/apex/CareMeridianEvaluationEdit?id='+evaluation.id);
        } else if(evaluation.RecordTypeId == Utility.getEvaluationRecordType('RestraintEvent')){
        	returnURL = new PageReference('/apex/EvalDynamic?evalId='+evaluation.Id+'&evalType=Restraint Event&opGrp=Care+Meridian');
        }else if (evaluation.RecordTypeId == Utility.getEvaluationRecordType('CMShiftAssessment')) {
        	/*if(evaluation.OwnerId == UserInfo.getUserId() && evaluation.Status__c == 'Draft') {
        	 returnURL = new PageReference('/apex/CMShiftAssessmentEdit?id='+evaluation.id);
        	} else if(evaluation.OwnerId != UserInfo.getUserId()){
        		isShift = true;
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only Owner ('+evaluation.Owner.Name+') can Edit this Assessment'));
        		return null;
        	} else if(evaluation.Status__c != 'Draft'){
        		isShift = true;
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot Edit the Assessments with status as '+evaluation.Status__c));
        		return null;
        	}*/
        	returnURL = new PageReference('/apex/EvalDynamic?evalId=' + evaluation.Id + '&opGrp=Care Meridian&evalType=Head to Toe');
		} else if(evaluation.RecordTypeId == Utility.getEvaluationRecordType('CNA Workbook')) {
			returnURL = new PageReference('/apex/EvalDynamic?evalId=' + evaluation.Id + '&opGrp=Care Meridian&evalType=CNA+Workbook');
		}

        return returnURL;
    }
}