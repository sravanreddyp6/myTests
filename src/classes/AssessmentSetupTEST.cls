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
@isTest(SeeAllData=true)
private class AssessmentSetupTEST {

    static testMethod void myUnitTest() {
        
        String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
        
        Account Accnt = new Account(
            RecordTypeID=RecTypeId,
            FirstName= 'Test FName',
            LastName='Test LName',
            PersonMailingStreet='test@yahoo.com',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonMailingStateCode='NC',
            PersonEmail='test@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678'
        );
        insert Accnt;
        
        List<Account> testAcct = [Select Id, PersonContactId From Account a WHERE a.Id = :Accnt.Id];
        System.Debug('What is in testAcct: ' + testAcct);
        Id aContactId = testAcct[0].PersonContactId;
        Id aAccountId = testAcct[0].Id;
        
        Admission__c Adm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = aContactId,
            Effective_Date__c = date.today(),
            Network_Offering__c = 'ARY'
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
            Interval__c = 'Intake',
            Assessment_Date__c = date.today(),
            Name = 'TEST ASSMT',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = aAccountId,
            TFC_Family_Vistas__c = 'No',
            Admission__c = Adm.Id
        );
        insert testAssmt;
        
        Assessment__c testAssmt2 = new Assessment__c(
            Interval__c = 'Quarterly',
            Quarter__c = 1,
            Assessment_Date__c = date.today(),
            Name = 'TEST ASSMT2',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = aAccountId,
            TFC_Family_Vistas__c = 'No',
            Admission__c = Adm.Id           
        );
        insert testAssmt2;
        
        Assessment__c testAssmt3 = new Assessment__c(
            Interval__c = 'Discharge',
            Assessment_Date__c = date.today(),
            Name = 'TEST ASSMT3',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = aAccountId,
            TFC_Family_Vistas__c = 'No',
            Admission__c = Adm.Id
        );
        insert testAssmt3;      
        
    }
}