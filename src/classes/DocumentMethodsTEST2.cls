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
private class DocumentMethodsTEST2 {

    static testMethod void myUnitTest() {
        // Get System Admin profile ID.
        String ProfileId = [select ProfileId from User where (Profile.Name='System Administrator') LIMIT 1].ProfileId;

        User usr = new User(USERNAME='testForDocs@thementornetwork.com',
               LASTNAME = 'TestLastName',
               FIRSTNAME = 'TestFirstName',
               EMAIL = 'josh.gilliam@thementornetwork.com',
               ALIAS = 'ttest',
               COMMUNITYNICKNAME = 'testForDocs.test',
               TIMEZONESIDKEY = 'America/New_York',
               LOCALESIDKEY = 'en_US', 
               EMAILENCODINGKEY = 'ISO-8859-1',
               PROFILEID = ProfileId,
               LANGUAGELOCALEKEY = 'en_US',                                
               ISACTIVE = true,
               legal_custodian__c=true); 
        insert usr; 

        User usr2 = new User(USERNAME='testForDocs2@thementornetwork.com',
               LASTNAME = 'TestLastName2',
               FIRSTNAME = 'TestFirstName2',
               EMAIL = 'josh.gilliam@thementornetwork.com',
               ALIAS = 'ttest2',
               COMMUNITYNICKNAME = 'testForDocs2.test2',
               TIMEZONESIDKEY = 'America/New_York',
               LOCALESIDKEY = 'en_US', 
               EMAILENCODINGKEY = 'ISO-8859-1',
               PROFILEID = ProfileId,
               LANGUAGELOCALEKEY = 'en_US',                                
               ISACTIVE = true,
               legal_custodian__c=true);
        insert usr2;
        
        /*
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
            Effective_Date__c = date.newInstance(2013, 1, 1),
            Status__c = 'Active'
        );
        insert Adm;
        
        Service_Assignment__c myData.theSA = new Service_Assignment__c(
            Name = 'TEST SERV ASSIGN',
            Admission__c = Adm.Id,
            Person_Being_Served__c = aContactId,
            Start_Date__c = date.newInstance(2013, 1, 1),
            End_Date__c = date.newInstance(2014, 12, 31),
            Status__c = 'Inactive',
            Program__c = 'IFCS'
        );
        insert myData.theSA;
        */
        
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
            myData.theSA.Start_Date__c = date.newInstance(2013, 1, 1);
            myData.theSA.End_Date__c = date.newInstance(2014, 12, 31);
            myData.theSA.Status__c = 'Inactive';
        update myData.theSA;
        
        Document__c caseDoc = new Document__c(
            Name = 'Case Document',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Client Tx Start',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 1,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc;

        Document__c caseDoc2 = new Document__c(
            Name = 'Case Document 2',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Calendar Month End',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 3,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc2;

        Document__c caseDoc3 = new Document__c(
            Name = 'Case Document 3',
            Active__c = true,
            Auto_Include__c = false,
            Relative_Due_Date_Event__c = 'Client Tx End',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 5,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc3;        

        Document__c caseDoc4 = new Document__c(
            Name = 'Case Document 4',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Client Tx End',
            Relative_Due_Date_UOM__c = 'Week(s)',
            Relative_Due_Date_Units__c = 5,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc4; 

        Document__c caseDoc5 = new Document__c(
            Name = 'Case Document 5',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Client Tx End',
            Relative_Due_Date_UOM__c = 'Month(s)',
            Relative_Due_Date_Units__c = 5,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc5; 

        Document__c caseDoc6 = new Document__c(
            Name = 'Case Document 6',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Calendar Month End',
            Relative_Due_Date_UOM__c = 'Week(s)',
            Relative_Due_Date_Units__c = 3,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc6;

        Document__c caseDoc7 = new Document__c(
            Name = 'Case Document 7',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Calendar Month End',
            Relative_Due_Date_UOM__c = 'Month(s)',
            Relative_Due_Date_Units__c = 3,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc7;

        Document__c caseDoc8 = new Document__c(
            Name = 'Case Document 8',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Calendar Quarter End',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 1,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc8;
        
        Document__c caseDoc9 = new Document__c(
            Name = 'Case Document 9',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Calendar Quarter End',
            Relative_Due_Date_UOM__c = 'Weeks(s)',
            Relative_Due_Date_Units__c = 1,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc9;
        
        Document__c caseDoc10 = new Document__c(
            Name = 'Case Document 10',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Calendar Quarter End',
            Relative_Due_Date_UOM__c = 'Month(s)',
            Relative_Due_Date_Units__c = 1,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc10;
        
        Document__c caseDoc11 = new Document__c(
            Name = 'Case Document 11',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'MENTOR Fiscal Year End',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 1,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc11;
        
        Document__c caseDoc12 = new Document__c(
            Name = 'Case Document 12',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'MENTOR Fiscal Year End',
            Relative_Due_Date_UOM__c = 'Week(s)',
            Relative_Due_Date_Units__c = 1,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc12;
        
        Document__c caseDoc13 = new Document__c(
            Name = 'Case Document 13',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'MENTOR Fiscal Year End',
            Relative_Due_Date_UOM__c = 'Month(s)',
            Relative_Due_Date_Units__c = 3,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc13;       

        Document__c caseDoc14 = new Document__c(
            Name = 'Case Document 14',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Client Tx End',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 1,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc14;

        Document__c caseDoc15 = new Document__c(
            Name = 'Case Document 15',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Client Tx Start',
            Relative_Due_Date_UOM__c = 'Week(s)',
            Relative_Due_Date_Units__c = 1,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc15;
                
        Document__c caseDoc16 = new Document__c(
            Name = 'Case Document 16',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Client Tx Start',
            Relative_Due_Date_UOM__c = 'Month(s)',
            Relative_Due_Date_Units__c = 1,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc16;
                
        Document__c caseDoc17 = new Document__c(
            Name = 'Case Document 17',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Monthly Anniversary of Client Tx Start',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 1,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc17;
                
        Document__c caseDoc18 = new Document__c(
            Name = 'Case Document 18',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Monthly Anniversary of Client Tx Start',
            Relative_Due_Date_UOM__c = 'Week(s)',
            Relative_Due_Date_Units__c = 1,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc18;
                            
        Document__c caseDoc19 = new Document__c(
            Name = 'Case Document 19',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Monthly Anniversary of Client Tx Start',
            Relative_Due_Date_UOM__c = 'Month(s)',
            Relative_Due_Date_Units__c = 1,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc19;
                
        Document__c caseDoc20 = new Document__c(
            Name = 'Case Document 20',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Quarterly Anniversary of Client Tx Start',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 1,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc20;
                
        Document__c caseDoc21 = new Document__c(
            Name = 'Case Document 21',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Quarterly Anniversary of Client Tx Start',
            Relative_Due_Date_UOM__c = 'Week(s)',
            Relative_Due_Date_Units__c = 1,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc21;
                            
        Document__c caseDoc22 = new Document__c(
            Name = 'Case Document 22',
            Active__c = true,
            Auto_Include__c = true,
            Relative_Due_Date_Event__c = 'Quarterly Anniversary of Client Tx Start',
            Relative_Due_Date_UOM__c = 'Month(s)',
            Relative_Due_Date_Units__c = 1,
            Required_From_Date__c = date.newInstance(2013, 1, 1),
            Required_To_Date__c = date.newInstance(2013, 12, 31),
            State__c = 'NC',
            Type__c = 'Case Document'
        );
        insert caseDoc22;
                                                    
        ServiceAssignment_Document_JO__c mySadjo = new ServiceAssignment_Document_JO__c(
            Document__c = caseDoc.Id,
            Service_Assignment__c = myData.theSA.id,
            Filed_Date_Time__c = datetime.newInstance(2013,10,20,12,30,00),
            File_Status__c = 'Not Filed',
            Relative_Due_Date_Event__c = 'Client Tx Start',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 1,
            Relative_Due_Date_Resolved__c = date.newInstance(2013,1,2),
            Due_From_Employee__c = usr.Id
        );
        insert mySadjo;
        
        ServiceAssignment_Document_JO__c mySadjo2 = new ServiceAssignment_Document_JO__c(
            Document__c = caseDoc2.Id,
            Service_Assignment__c = myData.theSA.id,
            Filed_Date_Time__c = datetime.newInstance(2013,10,20,12,30,00),
            File_Status__c = 'Not Filed',
            Relative_Due_Date_Event__c = 'Client Tx Start',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 7,
            Relative_Due_Date_Resolved__c = date.newInstance(2013,1,8),
            Due_From_Employee__c = usr.Id
        );
        insert mySadjo2;

        ServiceAssignment_Document_JO__c mySadjo3 = new ServiceAssignment_Document_JO__c(
            Document__c = caseDoc2.Id,
            Service_Assignment__c = myData.theSA.id,
            File_Status__c = 'Filed',
            Relative_Due_Date_Event__c = 'Client Tx Start',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 7,
            Relative_Due_Date_Resolved__c = date.newInstance(2013,2,8),
            Due_From_Employee__c = usr.Id
        );
        insert mySadjo3;

        ServiceAssignment_Document_JO__c mySadjo4 = new ServiceAssignment_Document_JO__c(
            Document__c = caseDoc3.Id,
            Service_Assignment__c = myData.theSA.id,
            File_Status__c = 'Not Filed',
            Relative_Due_Date_Event__c = 'Client Tx Start',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 7,
            Relative_Due_Date_Resolved__c = date.newInstance(2013,2,8),
            Due_From_Employee__c = usr.Id
        );
        insert mySadjo4;        

        ServiceAssignment_Document_JO__c mySadjo5 = new ServiceAssignment_Document_JO__c(
            Document__c = caseDoc4.Id,
            Service_Assignment__c = myData.theSA.id,
            File_Status__c = 'Not Filed',
            Relative_Due_Date_Event__c = 'Client Tx Start',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 7,
            Relative_Due_Date_Resolved__c = date.newInstance(2013,2,8),
            Due_From_Employee__c = usr.Id
        );
        insert mySadjo5;
        
        ServiceAssignment_Document_JO__c mySadjo6 = new ServiceAssignment_Document_JO__c(
            Document__c = caseDoc5.Id,
            Service_Assignment__c = myData.theSA.id,
            File_Status__c = 'Not Filed',
            Relative_Due_Date_Event__c = 'Client Tx Start',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 7,
            Relative_Due_Date_Resolved__c = date.newInstance(2013,2,8),
            Due_From_Employee__c = usr.Id
        );
        insert mySadjo6;
        
        ServiceAssignment_Document_JO__c mySadjo7 = new ServiceAssignment_Document_JO__c(
            Document__c = caseDoc6.Id,
            Service_Assignment__c = myData.theSA.id,
            File_Status__c = 'Not Filed',
            Relative_Due_Date_Event__c = 'Client Tx Start',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 7,
            Relative_Due_Date_Resolved__c = date.newInstance(2013,2,8),
            Due_From_Employee__c = usr.Id
        );
        insert mySadjo7;
        
        TMN_Contract__c myContract = new TMN_Contract__c(
            Name = 'Name',
            ApprovalStage__c = 'Approved',
            Status__c = 'Active'
        );
        insert myContract;
        
        ServiceAssignment_Contract_JO__c mySacjo = new ServiceAssignment_Contract_JO__c(
            Service_Assignment__c = myData.theSA.id,
            Contract__c = myContract.Id
        );
        insert mySacjo;
        
        Contract_Document_JO__c myContractDocJo = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc.Id
        );
        insert myContractDocJo;

        Contract_Document_JO__c myContractDocJo2 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc2.Id
        );
        insert myContractDocJo2;

        Contract_Document_JO__c myContractDocJo3 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc3.Id
        );
        insert myContractDocJo3;        

        Contract_Document_JO__c myContractDocJo4 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc4.Id
        );
        insert myContractDocJo4;  
        
        Contract_Document_JO__c myContractDocJo5 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc5.Id
        );
        insert myContractDocJo5;  
        
        Contract_Document_JO__c myContractDocJo6 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc6.Id
        );
        insert myContractDocJo6;  
        
        Contract_Document_JO__c myContractDocJo7 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc7.Id
        );
        insert myContractDocJo7;  

        Contract_Document_JO__c myContractDocJo8 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc8.Id
        );
        insert myContractDocJo8;

        Contract_Document_JO__c myContractDocJo9 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc9.Id
        );
        insert myContractDocJo9;        
        
        Contract_Document_JO__c myContractDocJo10 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc10.Id
        );
        insert myContractDocJo10;
        
        Contract_Document_JO__c myContractDocJo11 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc11.Id
        );
        insert myContractDocJo11;
        
        Contract_Document_JO__c myContractDocJo12 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc12.Id
        );
        insert myContractDocJo12;
        
        Contract_Document_JO__c myContractDocJo13 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc13.Id
        );
        insert myContractDocJo13;               

        Contract_Document_JO__c myContractDocJo14 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc14.Id
        );
        insert myContractDocJo14;

        Contract_Document_JO__c myContractDocJo15 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc15.Id
        );
        insert myContractDocJo15;

        Contract_Document_JO__c myContractDocJo16 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc16.Id
        );
        insert myContractDocJo16;        

        Contract_Document_JO__c myContractDocJo17 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc17.Id
        );
        insert myContractDocJo17;  
        
        Contract_Document_JO__c myContractDocJo18 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc18.Id
        );
        insert myContractDocJo18;  
        
        Contract_Document_JO__c myContractDocJo19 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc19.Id
        );
        insert myContractDocJo19;  
        
        Contract_Document_JO__c myContractDocJo20 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc20.Id
        );
        insert myContractDocJo20;  
                
        Contract_Document_JO__c myContractDocJo21 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc21.Id
        );
        insert myContractDocJo21;  
                
        Contract_Document_JO__c myContractDocJo22 = new Contract_Document_JO__c(
            Contract__c = myContract.Id,
            Document__c = caseDoc22.Id
        );
        insert myContractDocJo22;  
                
        
        Program_Document_Xref__c myProgramDocXref = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc.Id
        );
        insert myProgramDocXref;

        Program_Document_Xref__c myProgramDocXref2 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc2.Id
        );
        insert myProgramDocXref2;

        Program_Document_Xref__c myProgramDocXref3 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc3.Id
        );
        insert myProgramDocXref3;

        Program_Document_Xref__c myProgramDocXref4 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc4.Id
        );
        insert myProgramDocXref4;
        
        Program_Document_Xref__c myProgramDocXref5 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc5.Id
        );
        insert myProgramDocXref5;
        
        Program_Document_Xref__c myProgramDocXref6 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc6.Id
        );
        insert myProgramDocXref6;
        
        Program_Document_Xref__c myProgramDocXref7 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc7.Id
        );
        insert myProgramDocXref7;

        Program_Document_Xref__c myProgramDocXref8 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc8.Id
        );
        insert myProgramDocXref8;
        
        Program_Document_Xref__c myProgramDocXref9 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc9.Id
        );
        insert myProgramDocXref9;
        
        Program_Document_Xref__c myProgramDocXref10 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc10.Id
        );
        insert myProgramDocXref10;
        
        Program_Document_Xref__c myProgramDocXref11 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc11.Id
        );
        insert myProgramDocXref11;
            
        Program_Document_Xref__c myProgramDocXref12 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc12.Id
        );
        insert myProgramDocXref12;
            
        Program_Document_Xref__c myProgramDocXref13 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc13.Id
        );
        insert myProgramDocXref13;

        Program_Document_Xref__c myProgramDocXref14 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc14.Id
        );
        insert myProgramDocXref14;

        Program_Document_Xref__c myProgramDocXref15 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc15.Id
        );
        insert myProgramDocXref15;

        Program_Document_Xref__c myProgramDocXref16 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc16.Id
        );
        insert myProgramDocXref16;

        Program_Document_Xref__c myProgramDocXref17 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc17.Id
        );
        insert myProgramDocXref17;
        
        Program_Document_Xref__c myProgramDocXref18 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc18.Id
        );
        insert myProgramDocXref18;
        
        Program_Document_Xref__c myProgramDocXref19 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc19.Id
        );
        insert myProgramDocXref19;
        
        Program_Document_Xref__c myProgramDocXref20 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc20.Id
        );
        insert myProgramDocXref20;
        
        Program_Document_Xref__c myProgramDocXref21 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc21.Id
        );
        insert myProgramDocXref21;
        
        Program_Document_Xref__c myProgramDocXref22 = new Program_Document_Xref__c(
            Program__c = 'IFCS',
            Document__c = caseDoc22.Id
        );
        insert myProgramDocXref22;
                       
             
        DocumentMethods.ChangeDueFrom(myData.theSA, usr2.Id);
        
        // Check to confirm that the Due_From_Employee__c has changed for the first two docs that were Not Filed, but NOT for the third that was Filed.
        List<ServiceAssignment_Document_JO__c> doc1DueFrom = [ SELECT Due_From_Employee__c FROM ServiceAssignment_Document_JO__c WHERE Id = :mySadjo.Id ];
        for(ServiceAssignment_Document_JO__c d : doc1DueFrom) {
               System.assert(d.Due_From_Employee__c==usr2.Id);
        }
        List<ServiceAssignment_Document_JO__c> doc2DueFrom = [ SELECT Due_From_Employee__c FROM ServiceAssignment_Document_JO__c WHERE Id = :mySadjo2.Id ];
        for(ServiceAssignment_Document_JO__c d : doc2DueFrom) {
               System.assert(d.Due_From_Employee__c==usr2.Id);
        }
        List<ServiceAssignment_Document_JO__c> doc3DueFrom = [ SELECT Due_From_Employee__c FROM ServiceAssignment_Document_JO__c WHERE Id = :mySadjo3.Id ];
        for(ServiceAssignment_Document_JO__c d : doc3DueFrom) {
               System.assert(d.Due_From_Employee__c==usr.Id);
        }        

        List<Service_Assignment__c> listOfSas = new List<Service_Assignment__c>();
        listOfSas.add(myData.theSA);

        DocumentMethods.docPop(listOfSas);

    }
}