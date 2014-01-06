trigger AssesmentStatusUpdate on Assessment__c (before update) {
    
    List<Assessment__c> theseAssmts = new List<Assessment__c>();
    
    theseAssmts = trigger.new;
    
    for(Assessment__c thisAssmt : theseAssmts){
    
        Integer countOfAnswersExpected = [SELECT COUNT() FROM Assessment_Question__c WHERE Assessment_Type__c = :thisAssmt.Assessment_Type_Id__c];
        System.Debug('What is in countOfAnswersExpected?:' + countOfAnswersExpected);
        System.Debug('What is in thisAssmt.AssessmentResponseCount__c?:' + thisAssmt.AssessmentResponseCount__c);
        System.Debug('thisAssmt.Status__c: ' + thisAssmt.Status__c);
        System.Debug('thisAssmt.Assessment_Type__r.name: ' + thisAssmt.Assessment_Type__r.name);

        if((countOfAnswersExpected > thisAssmt.AssessmentResponseCount__c) && (thisAssmt.Status__c == 'Locked' && thisAssmt.Assessment_Type_Name__c =='CANS')){
            System.debug('The assessment submit error IF block ran!');
            thisAssmt.addError('All questions for the assessment have not been answered. Please answer all questions prior to submitting the assessment.'); 
        }
    }
}