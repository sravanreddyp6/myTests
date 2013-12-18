trigger AssessmentCreate on Assessment__c (after insert) {
    
    AssessmentSetup.insertDomains(trigger.new);
    
}