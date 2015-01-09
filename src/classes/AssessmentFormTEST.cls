/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AssessmentFormTEST {

    static testMethod void myUnitTest() {
        /*
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
        
//        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
//        User testUser = new User(
//            Alias = 'standt', 
//            Email='standarduser@testorg.com', 
//            EmailEncodingKey='UTF-8', 
//            LastName='Testing', 
//            LanguageLocaleKey='en_US', 
//            LocaleSidKey='en_US', 
//            ProfileId = p.Id, 
//            TimeZoneSidKey='America/Los_Angeles', 
//            UserName='standarduser@testorg.com'
//        );
//        insert testUser;
        
        List<Account> testAcct = [Select Id, PersonContactId From Account a WHERE a.Id = :Accnt.Id];
        System.Debug('What is in testAcct: ' + testAcct);
        Id aContactId = testAcct[0].PersonContactId;
        Id aAccountId = testAcct[0].Id;
        
        Admission__c Adm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = aContactId,
            Effective_Date__c = date.today(),
            Discharged_Date__c = date.today(),
            Status__c = 'Discharged',
            Discharged_Status__c = 'Positive',
            Reason_for_Discharge__c = 'TEST REASON FOR DISCHARGE',
            Network_Offering__c = 'ARY'
        );
        insert Adm;
        
        Admission__c Adm2 = new Admission__c(
            Name = 'TEST ADM2',
            Person_Being_Served__c = aContactId,
            Effective_Date__c = date.today(),
            Network_Offering__c = 'ARY'
        );
        insert Adm2;
        */
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        
        Assessment_Type__c testAssmtType = new Assessment_Type__c(
            Name = 'CANS'           
        );
        insert testAssmtType;
            
        List<Assessment_Type__c> testAssmtTypeId = [SELECT Id FROM Assessment_Type__c WHERE Name = 'CANS' LIMIT 1];
        
        Assessment_Domain__c testDomain = new Assessment_Domain__c(
            Name = 'TEST DOMAIN',
            Assessment_Type__c = testAssmtTypeId[0].Id
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
//            OwnerID = testUser.Id,
            Interval__c = 'Intake',
            Name = 'TEST ASSMT',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = myData.theAccount.Id,
            TFC_Family_Vistas__c = 'No'
        );
        insert testAssmt;
        
        Assessment_Domain_Result__c testADR = new Assessment_Domain_Result__c(
            Assessment__c = testAssmt.Id,
            Assessment_Domain__c = testDomain.Id
        );
        insert testADR;
        
        Assessment_Response__c testAR = new Assessment_Response__c(
            Assessment__c = testAssmt.Id,
            Assessment_Domain_Result__c = testADR.Id
        );
        insert testAR;
        
        AssessmentForm test = new AssessmentForm(testAssmt);
        
        test.LoadData(testAssmt);
        test.myUpsert();
        List<Assessment_Domain_Result__c> testThisRecordsDomainsList = new List<Assessment_Domain_Result__c>();
        testThisRecordsDomainsList = test.ThisRecordsDomains;
        test.getMapDomains();
        test.getMapAnswers();
        test.getMapQuestions();
    }
}