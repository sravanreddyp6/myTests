@isTest
private class Assessment_FAD_Notifications_Test{
    static testMethod void myUnitTest() {
        //Assessment_Fad_TestData.createTestData();
        //Assessment_FAD_Notifications aN = new Assessment_FAD_Notifications('SELECT Id, AccountPerson__c, AccountPerson__r.Id,  AccountPerson__r.PersonContactId, Admission__c, Admission__r.Name, Assessment_Date__c,  CreatedDate, OwnerId, Interval__c, Quarter__c, Assessment_Type__c, Approval_Status__c,  Assessment_Type__r.Name, Admission__r.Person_Being_Served__r.Account.LastName, Admission__r.Person_Being_Served__r.Account.FirstName, Owner.LastName, Owner.FirstName, Owner.Email, Status__c FROM Assessment__c  ORDER BY Assessment_Date__c LIMIT 200');
             
    
        //ID batchprocessid = Database.executeBatch(aN, 200);
        String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') LIMIT 1].Id;
        
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
        
//      Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
//      User testUser = new User(
//          Alias = 'standt', 
//          Email='standarduser@testorg.com', 
//              EmailEncodingKey='UTF-8', 
//              LastName='Testing', 
//              LanguageLocaleKey='en_US', 
//              LocaleSidKey='en_US', 
//              ProfileId = p.Id, 
//              TimeZoneSidKey='America/Los_Angeles', 
//              UserName='standarduser@testorg.com'
//      );
//      insert testUser;
        
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
        
        Service_Assignment__c SA1 = new Service_Assignment__c(
            phase_1_Start_Date__c = system.today().addDays(-7),
            Admission__c = adm2.id,
            Person_Being_served__c = aContactId,
            Program__c = 'IFCS'
        
        );
        insert SA1;
        Service_Assignment__c SA2 = new Service_Assignment__c(
            phase_1_Start_Date__c = system.today().addDays(-80),
            Admission__c = adm2.id,
            Person_Being_served__c = aContactId,
            Program__c = 'IFCS'
        
        );
        insert SA2;   
        Service_Assignment__c SA3 = new Service_Assignment__c(
            phase_1_Start_Date__c = system.today().addDays(-160),
            Admission__c = adm2.id,
            Person_Being_served__c = aContactId,
            Program__c = 'IFCS'
        
        );
        //insert SA3;               
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
//          OwnerID = testUser.Id,
            Interval__c = 'Intake',
            Name = 'TEST ASSMT',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = aAccountId,
            TFC_Family_Vistas__c = 'No'
        );
        insert testAssmt;
        
        Assessment__c testAssmt2 = new Assessment__c(
            Admission__c = Adm.Id,
            Interval__c = 'Quarterly',
            Quarter__c = 1,
            Assessment_Date__c = date.newinstance(2012, 09, 17),
            Name = 'TEST ASSMT2',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = aAccountId,
            TFC_Family_Vistas__c = 'No'         
        );
        insert testAssmt2;
        
        Assessment__c testAssmt3 = new Assessment__c(
            Admission__c = Adm2.Id,
            Interval__c = 'Intake',
            Assessment_Date__c = date.newinstance(2012, 02, 17),
            Name = 'TEST ASSMT3',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = aAccountId,
            TFC_Family_Vistas__c = 'No'         
        );
        insert testAssmt3;
        
        Assessment__c testAssmt4 = new Assessment__c(
            Admission__c = Adm2.Id,
            Interval__c = 'Discharge',
            Assessment_Date__c = date.newinstance(2012, 04, 17),
            Name = 'TEST ASSMT4',
            Assessment_Type__c = testAssmtTypeId[0].Id,
            AccountPerson__c = aAccountId,
            TFC_Family_Vistas__c = 'No'         
        );
        insert testAssmt4;
        
        Assessment_FAD_Notifications aN3 = new Assessment_FAD_Notifications('SELECT Id, Status__c FROM Service_Assignment__c');
               

            ID batchprocessid = Database.executeBatch(aN3, 200);
            
        sa2.phase_1_Start_Date__c = system.today().addDays(-160); 
            Assessment_FAD_Notifications     aN4 = new Assessment_FAD_Notifications('SELECT Id, Status__c FROM Service_Assignment__c');
               

            ID batchprocessid2 = Database.executeBatch(aN4, 200);

        
    }

}