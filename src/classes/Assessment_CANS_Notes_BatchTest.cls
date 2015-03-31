@isTest
private class Assessment_CANS_Notes_BatchTest {
	
	@isTest static void test_method_one() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();        
        
        Assessment_Type__c testAssmtType = new Assessment_Type__c(
            Name = 'CANS'           
        );
        insert testAssmtType;
            
        List<Assessment_Type__c> testAssmtTypeId = [SELECT Id FROM Assessment_Type__c WHERE Name = 'CANS' LIMIT 1];
        
        Assessment_Domain__c testDomain = new Assessment_Domain__c(
            Name = 'TEST DOMAIN'
        );
        insert testDomain;
        
        Assessment_Question__c testQuestion = new Assessment_Question__c(
            Question_Title__c = 'TEST QUESTION',
            Question_Description__c = 'A TEST QUESTION',
            Question_Domain__c = testDomain.Id
        );
        insert testQuestion;
        
        Assessment__c testAssmt = new Assessment__c(
            Admission__c = myData.theAdm.Id,
            Assessment_Date__c = date.newinstance(2012, 02, 17),
//          OwnerID = testUser.Id,
            Interval__c = 'Intake',
            Name = 'TEST ASSMT',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = myData.theAccount.Id,
            TFC_Family_Vistas__c = 'No', 
            Status__c = 'Locked'
        );
        insert testAssmt;
        
        Assessment__c testAssmt2 = new Assessment__c(
            Admission__c = myData.theAdm.Id,
            Interval__c = 'Quarterly',
            Quarter__c = 1,
            Assessment_Date__c = date.newinstance(2012, 03, 17),
            Name = 'TEST ASSMT2',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = myData.theAccount.Id,
            TFC_Family_Vistas__c = 'No', 
            Status__c = 'Locked'        
        );
        insert testAssmt2;
        
        Assessment__c testAssmt3 = new Assessment__c(
            Admission__c = myData.theAdm.Id,
            Interval__c = 'Discharge',
            Assessment_Date__c = date.newinstance(2012, 04, 17),
            Name = 'TEST ASSMT3',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = myData.theAccount.Id,
            TFC_Family_Vistas__c = 'No',         
            Status__c = 'Locked' 
        );
        insert testAssmt3;

            Test.startTest();
                    String CRON_EXP = '0 0 0 1 1 ? 2025';  
                    String jobId = System.schedule('testScheduledApex', CRON_EXP, new Assessment_CANS_Notes_Sch() );

                    CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];


            Test.stopTest();


	}
	

	
}