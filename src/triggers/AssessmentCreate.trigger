trigger AssessmentCreate on Assessment__c (before insert, after insert) {
    if (Trigger.isAfter) {
        AssessmentSetup.insertDomains(trigger.new);
    } else if (Trigger.isBefore) {
    	// We have to clone the answers for the hardcoded questions in the
    	// before trigger, because we can't modify the triggered record in the
    	// after trigger.
    	AssessmentSetup.cloneHardcodedAnswers(trigger.new);
    }
    
}