@isTest
private class Assessment_CANS_RPT_ImpAtDischarge_Test {
    
  @isTest static void test_method_one() {
            TMN_Generic_Core_TestData myTestData = new TMN_Generic_Core_TestData();
            
            createAssessData();

            Assessment__c CANs1 = TMN_Generic_Core_TestData.createAssessment(myTestData.theAdm, myTestData.theSA, 'CANS', 'Locked', null, false);
            CANs1.Interval__c = 'Intake';
            CANs1.Service_Line__c = 'TFC';
            update CANs1;
            
            Assessment__c CANs2 = TMN_Generic_Core_TestData.createAssessment(myTestData.theAdm, myTestData.theSA, 'CANS', 'Locked', null, false);
            CANs2.Interval__c = 'Discharge';
            CANs2.Service_Line__c = 'TFC';
            update CANs2;            
            
            myTestData.theSA.status__c = 'Inactive';
            myTestData.theSA.End_Date__c = system.today();
            update myTestData.theSA;
            
            myTestData.theAdm.Status__c = 'Discharged';
            myTestData.theAdm.Discharged_Status__c = 'Positive';
            myTestData.theAdm.Discharged_Date__c = system.today();
            myTestData.theAdm.Reason_for_Discharge__c = 'TEST REASON FOR DISCHARGE';
            update myTestData.theAdm;


            Assessment_CANS_RPT_ImpAtDischarge ClassInTest = new Assessment_CANS_RPT_ImpAtDischarge();
            ClassInTest.selectedCluster = 'Education';
            ClassInTest.selectedServiceLines.add('TFC');
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