@isTest
public with sharing class ServiceAssignment_Contract_JO_TEST {
    static testmethod void simpleTests() {
    
        String ProfileId = [select ProfileId from User where (Profile.Name='System Administrator') LIMIT 1].ProfileId;
        User usr = new User(
            USERNAME='test@tmn.com.test',
            LASTNAME = 'TestLastName',
            FIRSTNAME = 'TestFirstName',
            EMAIL = 'test@thementornetwork.com',
            ALIAS = 'ttest',
            COMMUNITYNICKNAME = 'test.test',
            TIMEZONESIDKEY = 'America/New_York',
            LOCALESIDKEY = 'en_US',
            EMAILENCODINGKEY = 'ISO-8859-1',
            PROFILEID = ProfileId,
            LANGUAGELOCALEKEY = 'en_US',
            ISACTIVE = true,
            legal_custodian__c=true,
            Contract_Approver__c=true
        );
        insert usr;
        usr.Reset_Password__c = true;
        update usr;
        
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
        Accnt = [SELECT Id, PersonContactId FROM Account WHERE Id=:Accnt.Id];

        Admission__c Adm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = Accnt.PersonContactId,
            Effective_Date__c = date.newInstance(2013, 1, 1),
            Status__c = 'Active',
            State__c = 'NC'
        );
        insert Adm;

        Service_Assignment__c sa = new Service_Assignment__c(
            Name = 'TEST SERV ASSIGN',
            Admission__c = Adm.Id,
            Person_Being_Served__c = Accnt.PersonContactId,
            Start_Date__c = date.newInstance(2013, 1, 1),
            Status__c = 'Active',
            Program__c = 'IFCS',
            Service_Line__c = 'Intensive In Home - FCT'
        );
        insert sa;
*/
TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();

        TMN_Contract__c contract = new TMN_Contract__c(
            Name = 'Test Contract',
            ApprovalStage__c = 'Approved',
            Approver_1__c = usr.Id,
            Value__c = 0.0,
            ValueAnnual__c = 0.0,
            Type_of_Contract__c = 'New',
            Submitted_for_approval__c = false,
            Status__c = 'Active',
            State__c = 'NC',
            SpendDown__c = 'N/A',
            ReadyForApproval__c = false,
            Operating_Group__c = 'Cambridge',
            LegalReviewRequired__c = false,
            FullyExecutedContractUploaded__c = false,
            DetailsComplete__c = false,
            Description__c = 'Test Contract Description',
            CriticalIndicatorsComplete__c = false,
            Contract_Number__c = '123456',
            CompleteAssignedApprovers__c = false,
            CheckListComplete__c = false,
            App_7_Compliance_Sign_Off__c = false,
            App_6_Compliance_Sign_Off__c = false,
            App_5_Compliance_Sign_Off__c = false,
            App_4_Compliance_Sign_Off__c = false,
            App_3_Compliance_Sign_Off__c = false,
            App_2_Compliance_Sign_Off__c = false,
            App_1_Compliance_Sign_Off__c = false
        );
        insert contract;
        ServiceAssignment_Contract_JO__c jo = new ServiceAssignment_Contract_JO__c(
            Contract__c = contract.Id,
            Service_Assignment__c = myData.theSA.id
        );
        insert jo;
        update jo;
        delete jo;
        undelete jo;
    }
}