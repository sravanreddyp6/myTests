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
private class ServiceAssignmentValidationTEST {

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
            Effective_Date__c = date.newInstance(2013, 1, 1),
            Discharged_Date__c = date.newInstance(2013, 6, 30),
            Status__c = 'Discharged',
            Discharged_Status__c = 'Positive',
            Reason_for_Discharge__c = 'TEST REASON FOR DISCHARGE'
        );
        insert Adm;

        Service_Assignment__c ServAssign = new Service_Assignment__c(
            Name = 'TEST SERV ASSIGN',
            Admission__c = Adm.Id,
            Person_Being_Served__c = aContactId,
            Start_Date__c = date.newInstance(2013, 1, 1),
            End_Date__c = date.newInstance(2013, 1, 31),
            Status__c = 'Inactive'
        );

        Service_Assignment__c ServAssign2 = new Service_Assignment__c(
            Name = 'TEST SERV ASSIGN 2',
            Admission__c = Adm.Id,
            Person_Being_Served__c = aContactId,
            Start_Date__c = date.newInstance(2013, 6, 1),
            End_Date__c = date.newInstance(2013, 6, 30),
            Status__c = 'Inactive'
        );

        Progress_Note__c ProgNote = new Progress_Note__c(
            Name = 'TEST PROGRESS NOTE',
            Admission__c = Adm.Id,
            Service_Assignment__c = ServAssign.Id,
            Person_Being_Served__c = aContactId,
            Start_Time__c = datetime.newInstance(2013, 1, 1, 11, 30, 0),
            End_Time__c = datetime.newInstance(2013, 1, 1, 13, 30, 0)
        );
        Progress_Note__c ProgNote2 = new Progress_Note__c(
            Name = 'TEST PROGRESS NOTE 2',
            Admission__c = Adm.Id,
            Service_Assignment__c = ServAssign.Id,
            Person_Being_Served__c = aContactId,
            Start_Time__c = datetime.newInstance(2013, 1, 3, 11, 30, 0),
            End_Time__c = datetime.newInstance(2013, 1, 3, 13, 30, 0)
        );

        Progress_Note__c ProgNote3 = new Progress_Note__c(
            Name = 'TEST PROGRESS NOTE 3',
            Admission__c = Adm.Id,
            Service_Assignment__c = ServAssign.Id,
            Person_Being_Served__c = aContactId,
            Start_Time__c = datetime.newInstance(2013, 1, 30, 11, 30, 0),
            End_Time__c = datetime.newInstance(2013, 1, 30, 13, 30, 0)
        );


        test.startTest();
        insert ServAssign;
        ServAssign.End_Date__c = date.newInstance(2013,2,1);
        upsert ServAssign;
        insert ServAssign2;
        insert ProgNote;
        //insert ProgNote2;
        //insert ProgNote3;

        List<Service_Assignment__c> myListOfServAssigns = new List<Service_Assignment__c>();
        myListOfServAssigns.add(ServAssign);
        myListOfServAssigns.add(ServAssign2);

        ServiceAssignmentValidation.checkProgressNoteEndDates(myListOfServAssigns);

        delete ServAssign;
        undelete ServAssign;

        ServAssign.End_Date__c = date.newInstance(2013, 1, 29);
        test.stopTest();

        ServiceAssignmentValidation myObj = new ServiceAssignmentValidation(true);
        System.assert(myObj.IsTriggerContext==true,'The IsTriggerContext variable does not equal true as expected!');
    }

    static testMethod void insertDocAndUpdateSa() {

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

        Service_Assignment__c ServAssign = new Service_Assignment__c(
            Name = 'TEST SERV ASSIGN',
            Admission__c = Adm.Id,
            Person_Being_Served__c = aContactId,
            Start_Date__c = date.newInstance(2013, 1, 1),
            Projected_Treatment_End_Date__c = date.newInstance(2013, 1, 31),
            Status__c = 'Active',
            Program__c = 'IFCS'
        );

        test.startTest();
        insert ServAssign;

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

        ServiceAssignment_Document_JO__c mySadjo = new ServiceAssignment_Document_JO__c(
            Document__c = caseDoc.Id,
            Service_Assignment__c = ServAssign.Id,
            Filed_Date_Time__c = datetime.newInstance(2013,10,20,12,30,00),
            File_Status__c = 'Filed',
            Relative_Due_Date_Event__c = 'Client Tx Start',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 1,
            Relative_Due_Date_Resolved__c = date.newInstance(2013,1,2)
        );
        insert mySadjo;

        ServiceAssignment_Document_JO__c mySadjo2 = new ServiceAssignment_Document_JO__c(
            Document__c = caseDoc2.Id,
            Service_Assignment__c = ServAssign.Id,
            Filed_Date_Time__c = datetime.newInstance(2013,10,20,12,30,00),
            File_Status__c = 'Filed',
            Relative_Due_Date_Event__c = 'Client Tx Start',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 7,
            Relative_Due_Date_Resolved__c = date.newInstance(2013,1,8)
        );
        insert mySadjo2;

        ServiceAssignment_Document_JO__c mySadjo3 = new ServiceAssignment_Document_JO__c(
            Document__c = caseDoc2.Id,
            Service_Assignment__c = ServAssign.Id,
            File_Status__c = 'Not Filed',
            Relative_Due_Date_Event__c = 'Client Tx Start',
            Relative_Due_Date_UOM__c = 'Day(s)',
            Relative_Due_Date_Units__c = 7
        );
        insert mySadjo3;

        ServAssign.End_Date__c = null;
        ServAssign.Projected_Treatment_End_Date__c = date.newInstance(2013,7,1);

        update ServAssign;

        TMN_Contract__c myContract = new TMN_Contract__c(
            Name = 'Name',
            ApprovalStage__c = 'Approved',
            Status__c = 'Active'
        );
        insert myContract;

        ServiceAssignment_Contract_JO__c mySacjo = new ServiceAssignment_Contract_JO__c(
            Service_Assignment__c = ServAssign.Id,
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

        myContract.Status__c = 'Cancelled';
        ServAssign.Projected_Treatment_End_Date__c = date.newInstance(2013,1,30);
        caseDoc2.Required_To_Date__c = date.newInstance(2013,1,2);
        update caseDoc2;

        update ServAssign;
/*
        ServAssign.Program__c = 'Miami';
        delete myContractDocJo;
        delete myContractDocJo2;

        update ServAssign;
*/
        test.stopTest();
    }
}