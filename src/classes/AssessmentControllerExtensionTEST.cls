@isTest
private class AssessmentControllerExtensionTEST {

    static testMethod void myUnitTest() {
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
            Assessment_Date__c = date.newinstance(2012, 06, 17),
            //OwnerID = testUser.Id,
            Interval__c = 'Intake',
            Name = 'TEST ASSMT',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = myData.theAccount.Id,
            TFC_Family_Vistas__c = 'No'
        );
        insert testAssmt;
        
        Assessment__c testAssmt2 = new Assessment__c(
            Admission__c = myData.theAdm.Id,
            Assessment_Date__c = date.newinstance(2012, 06, 17),
            //OwnerID = testUser.Id,
            Interval__c = 'Quarterly',
            Quarter__c = 1,
            Name = 'TEST ASSMT2',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = myData.theAccount.Id,
            TFC_Family_Vistas__c = 'No'
        );
        insert testAssmt2;
        System.Debug( 'AFter insert' + testAssmt2.TFC_Family_Vistas__c);
        PageReference pageRef = Page.AssessmentForm;
        Test.setCurrentPageReference(pageRef);
        system.debug('assess id = ' + testAssmt.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(testAssmt);
        AssessmentControllerExtension testACE = new AssessmentControllerExtension(sc);
    
        testACE.SaveAndLock();
        testACE.Unlock();
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(testAssmt2);
        AssessmentControllerExtension testACE2 = new AssessmentControllerExtension(sc2);
    System.Debug( 'AFter insert' + testAssmt2.TFC_Family_Vistas__c);
    
    if ( testACE2.disregardAllowed ) {
            System.Debug( testAssmt2.TFC_Family_Vistas__c);
            
            testACE2.setDisregard();
            
            testAssmt2 = [ select id, disregard__c from assessment__c where id = :testAssmt2.Id];
            
            System.AssertEquals( true, testAssmt2.disregard__c);
        }
        
        
        // WARNING - SaveAndLock resets the value of TFC Family Vistas to null which will cause a validation error on save.  
        testACE2.SaveAndLock();
        testACE2.Unlock();
        testACE2.SaveAndLock();
        
        
    
    }
}