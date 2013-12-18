trigger AssessmentCheckIntervals on Assessment__c (before insert) {
	AssessmentSetup.checkIntervals(trigger.new);
}