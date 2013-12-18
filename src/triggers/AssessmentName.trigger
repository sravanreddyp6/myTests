trigger AssessmentName on Assessment__c (after insert) {
    
	AssessmentSetup.nameAssessment(Trigger.new);
	    
}