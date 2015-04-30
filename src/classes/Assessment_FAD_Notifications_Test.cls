@isTest
private class Assessment_FAD_Notifications_Test{
    static testMethod void myUnitTest() {
  
        
        TMN_Generic_Core_TestData test1 = new TMN_Generic_Core_TestData();
                   
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
        
        id nothing = test1.theAdm.Id;
        
        Assessment__c testAssmt = new Assessment__c(
            Admission__c = test1.theAdm.Id,
            Assessment_Date__c = date.newinstance(2012, 06, 17),
//          OwnerID = testUser.Id,
            Interval__c = 'Intake',
            Name = 'TEST ASSMT',
            Assessment_Type__c = testAssmtType.Id,
            AccountPerson__c = test1.theAccount.id,
            TFC_Family_Vistas__c = 'No'
        );
        insert testAssmt;
        
        Assessment__c testAssmt2 = new Assessment__c(
            Admission__c = test1.theAdm.Id,
            Interval__c = 'Quarterly',
            Quarter__c = 1,
            Assessment_Date__c = date.newinstance(2012, 09, 17),
            Name = 'TEST ASSMT2',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = test1.theAccount.id,
            TFC_Family_Vistas__c = 'No'         
        );
        insert testAssmt2;
        /*
        Assessment__c testAssmt3 = new Assessment__c(
            Admission__c = Adm2.Id,
            Interval__c = 'Intake',
            Assessment_Date__c = date.newinstance(2012, 02, 17),
            Name = 'TEST ASSMT3',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = test1.theAccount.id,
            TFC_Family_Vistas__c = 'No'         
        );
        insert testAssmt3;
        
        Assessment__c testAssmt4 = new Assessment__c(
            Admission__c = Adm2.Id,
            Interval__c = 'Discharge',
            Assessment_Date__c = date.newinstance(2012, 04, 17),
            Name = 'TEST ASSMT4',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = test1.theAccount.id,
            TFC_Family_Vistas__c = 'No'         
        );
        insert testAssmt4;
        */
        Assessment_FAD_Notifications aN3 = new Assessment_FAD_Notifications('SELECT Id, Status__c FROM Service_Assignment__c');
               

            ID batchprocessid = Database.executeBatch(aN3, 200);
            
            test1.theSA.phase_1_Start_Date__c = system.today().addDays(-160); 
            Assessment_FAD_Notifications  aN4 = new Assessment_FAD_Notifications('SELECT Id, Status__c FROM Service_Assignment__c');
               

            ID batchprocessid2 = Database.executeBatch(aN4, 200);

        
    }

}