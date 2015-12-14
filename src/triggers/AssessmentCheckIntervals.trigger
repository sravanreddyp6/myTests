trigger AssessmentCheckIntervals on Assessment__c (before insert) {
   
   /*
   Assessment__c[] assessments;
    for(Assessment__c item : trigger.new){
        if(item.Assessment_Type_Name__c =='CANS'){
            assessments.add(item);
        }
    }
    */
    
    AssessmentSetup.checkIntervals(trigger.new);
}