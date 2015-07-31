@isTest
private class Report_Assessment_CANS_PBS_OverTime_test {
	
	@isTest static void test_method_one() {
            TMN_Generic_Core_TestData myTestData = new TMN_Generic_Core_TestData();
            
            createAssessData();

            Assessment__c CANs1 = TMN_Generic_Core_TestData.createAssessment(myTestData.theAdm, myTestData.theSA, 'ISSA', null, null, false);

            Report_Assessment_CANS_PBS_OverTime ClassInTest = new Report_Assessment_CANS_PBS_OverTime();
            ClassInTest.selectedPBS = myTestData.theAccount.id;
            ClassInTest.runRPT();
	}
	










   public static void createAssessData(){
            Assessment_Domain__c testDomain = new Assessment_Domain__c(
                Name = 'Other',
                Assessment_Type2__c = 'CANS'
            );
            insert testDomain;
            
            Assessment_Question__c testQuestion = new Assessment_Question__c(
                Question_Title__c = 'TEST QUESTION',
                Question_Description__c = 'A TEST QUESTION',
                Question_Domain__c = testDomain.Id
            );
            insert testQuestion;   
            
            Assessment_Question_Option__c op1 = new Assessment_Question_Option__c(Question__c = testQuestion.id, rating__c = '0');
            insert op1;
            
            Assessment_Question_Option__c op2 = new Assessment_Question_Option__c(Question__c = testQuestion.id, rating__c = '1');
            insert op2;            
    
    
    }	
	
}