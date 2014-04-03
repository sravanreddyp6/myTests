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
private class DocumentAddExtTEST {

    static testMethod void myUnitTest() {
		// Get System Admin profile ID.
		String ProfileId = [select ProfileId from User where (Profile.Name='System Administrator') LIMIT 1].ProfileId;

		User usr = new User(USERNAME='test@thementornetwork.com',
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
	           legal_custodian__c=true);    
        
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
            Status__c = 'Active',
            State__c = 'NC'
        );
        insert Adm;

       
        Service_Assignment__c ServAssign = new Service_Assignment__c(
        	Name = 'TEST SERV ASSIGN',
        	Admission__c = Adm.Id,
        	Person_Being_Served__c = aContactId,
        	Start_Date__c = date.newInstance(2013, 1, 1),
        	Status__c = 'Active',
        	Program__c = 'IFCS',
        	Service_Line__c = 'Intensive In Home - FCT'
        );
        insert ServAssign;

		TMN_Contract__c testContract = new TMN_Contract__c(
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
		insert testContract;
		
		TMN_Contract__c tempContract = [ SELECT Id FROM TMN_Contract__c WHERE Id = :testContract.Id LIMIT 1 ];
		System.debug('testContract.Id: ' + testContract.Id);
		System.assert(tempContract.Id==testContract.Id,'Contract Ids DO NOT MATCH');

    	Document__c caseDoc = new Document__c(
			Name = 'Case Document',
			Active__c = true,
			Auto_Include__c = false,
			Relative_Due_Date_Event__c = 'Client Tx Start',
			Relative_Due_Date_UOM__c = 'Day(s)',
			Relative_Due_Date_Units__c = 1,
			Required_From_Date__c = date.newInstance(2013, 1, 1),
			Required_To_Date__c = date.newInstance(2013, 12, 31),
			State__c = 'NC',
			Type__c = 'Case Document'
		);
		insert caseDoc;
		
		Contract_Document_JO__c conDocJo = new Contract_Document_JO__c(
			Contract__c = testContract.Id,
			Document__c = caseDoc.Id
		);
		insert conDocJo;

		ServiceAssignment_Contract_JO__c sacjo = new ServiceAssignment_Contract_JO__c(
			Contract__c = testContract.Id,
			Service_Assignment__c = ServAssign.Id
		);
		insert sacjo;
		
		Program_Document_Xref__c pdx1 = new Program_Document_Xref__c(
			Document__c = caseDoc.Id,
			Location__c = 'Raleigh',
			Program__c = 'IFCS',
			Service_Line__c = 'Intensive In Home - FCT'
		);
		insert pdx1;

/*		
		ServiceAssignment_Document_JO__c sadjo = new ServiceAssignment_Document_JO__c(
			Service_Assignment__c = ServAssign.Id,
			Document__c = caseDoc.Id,
			File_Status__c = 'Filed'
		);
		insert sadjo;
*/

		Service_Code__c servCode = new Service_Code__c(
			Program__c = 'IFCS',
			Location__c = 'Raleigh',
			Service_Line__c = 'Intensive In Home - FCT',
			Start_Date__c = date.newInstance(2013,1,1),
			Service_Value__c = 'H1234',
			Assessment_Only__c = false,
			State__c = 'NC'
		);
		insert servCode;
		
		ServiceAssignment_ServiceCode_JO__c sAsCjO = new ServiceAssignment_ServiceCode_JO__c(
			Service_Assignment__c = ServAssign.Id,
			Service_Code__c = servCode.Id
		);
		insert sAsCjO;
		        
        PageReference pageRef = Page.AddDoc;
        Test.setCurrentPage(pageRef);

		ApexPages.currentPage().getParameters().put('ServAssignIdParam', ServAssign.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(new ServiceAssignment_Document_JO__c());
        DocumentAddExt myObj = new DocumentAddExt(sc);
 
        myObj.currentSelectedDocId = caseDoc.Id;
        myObj.defaultDueDateInfo();
        myObj.resetToDefaults();
        
        myObj.rddUnits = '1';
        myObj.rddUom = 'Day(s)';
        myObj.rddEvent = 'Client Tx Start';
        myObj.theServAssignDocJo.Document__c = caseDoc.Id;
        myObj.theServAssignDocJo.Relative_Due_Date_Units__c = 1;
        myObj.theServAssignDocJo.Relative_Due_Date_UOM__c = 'Day(s)';
        myObj.theServAssignDocJo.Relative_Due_Date_Event__c = 'Client Tx Start';
        myObj.theServAssignDocJo.Due_From_Employee__c = usr.Id;
        myObj.theServAssignDocJo.File_Status__c = 'Filed';
        myObj.theServAssignDocJo.Filed_By__c = usr.Id;
        System.debug('What is in theServAssignDocJo: ' + myObj.theServAssignDocJo);
        myObj.saveDocXref();
        
    }
}