trigger AssessmentName on Assessment__c (after insert) {
   // 
   /*
   Assessment__c[] assessments;
    for(Assessment__c item : trigger.new){
        if(item.Assessment_Type_Name__c =='CANS'){
            assessments.add(item);
        }
    }assessments
    */
    AssessmentSetup.nameAssessment(trigger.new);
        
}