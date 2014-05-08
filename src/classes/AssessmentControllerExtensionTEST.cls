@isTest
private class AssessmentControllerExtensionTEST {

    static testMethod void myUnitTest() {
       
        String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
        
        Account Accnt = new Account(
            RecordTypeID=RecTypeId,
            FirstName= 'Test FName',
            LastName='Test LName',
            PersonMailingStreet='123 Test Street',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonMailingStateCode='NC',
            PersonEmail='test@yahoo.com',
            PersonHomePhone='12345678',
            PersonMobilePhone='12345678'
        );
        insert Accnt;
        
        //Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        //User testUser = new User(
        //    Alias = 'standt', 
        //    Email='standarduser@testorg.com', 
        //    EmailEncodingKey='UTF-8', 
        //    LastName='Testing', 
        //    LanguageLocaleKey='en_US', 
        //    LocaleSidKey='en_US', 
        //    ProfileId = p.Id, 
        //    TimeZoneSidKey='America/Los_Angeles', 
        //    UserName='tk421@testorg.com'
        //);
        //insert testUser;
        
        List<Account> testAcct = [Select Id, PersonContactId From Account a WHERE a.Id = :Accnt.Id];
        System.Debug('What is in testAcct: ' + testAcct);
        Id aContactId = testAcct[0].PersonContactId;
        Id aAccountId = testAcct[0].Id;
        
        Admission__c Adm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = aContactId,
            Effective_Date__c = date.today()
        );
        insert Adm;
        
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
            Admission__c = Adm.Id,
            Assessment_Date__c = date.newinstance(2012, 06, 17),
            //OwnerID = testUser.Id,
            Interval__c = 'Intake',
            Name = 'TEST ASSMT',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = aAccountId,
            TFC_Family_Vistas__c = 'No'
        );
        insert testAssmt;
        
        Assessment__c testAssmt2 = new Assessment__c(
            Admission__c = Adm.Id,
            Assessment_Date__c = date.newinstance(2012, 06, 17),
            //OwnerID = testUser.Id,
            Interval__c = 'Quarterly',
            Quarter__c = 1,
            Name = 'TEST ASSMT2',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = aAccountId,
            TFC_Family_Vistas__c = 'No'
        );
        insert testAssmt2;
      	System.Debug( 'AFter insert' + testAssmt2.TFC_Family_Vistas__c);
        PageReference pageRef = Page.AssessmentForm;
        Test.setCurrentPageReference(pageRef);
        
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