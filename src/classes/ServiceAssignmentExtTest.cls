@isTest
private class ServiceAssignmentExtTest {

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
		
    	Document__c fidDoc = new Document__c(
			Name = 'Fidelity Document',
			Active__c = true,
			Auto_Include__c = true,
			Required_From_Date__c = date.newInstance(2013, 1, 1),
			Required_To_Date__c = date.newInstance(2013, 12, 31),
			Phase_or_Level__c = 1,
			Order__c = 1,
			State__c = 'NC',
			Type__c = 'Fidelity Document',
			Program__c = 'IFCS',
			Service_Line__c = 'Intensive In Home - FCT'
		);
		insert fidDoc;

    	Document__c fidDoc2 = new Document__c(
			Name = 'Fidelity Document 2',
			Active__c = true,
			Auto_Include__c = true,
			Required_From_Date__c = date.newInstance(2013, 1, 1),
			Required_To_Date__c = date.newInstance(2013, 12, 31),
			Phase_or_Level__c = 2,
			Order__c = 1,
			State__c = 'NC',
			Type__c = 'Fidelity Document',
			Program__c = 'IFCS',
			Service_Line__c = 'Intensive In Home - FCT'
		);
		insert fidDoc2;

		ServiceAssignment_Contract_JO__c sacjo = new ServiceAssignment_Contract_JO__c(
			Contract__c = testContract.Id,
			Service_Assignment__c = ServAssign.Id
		);
		insert sacjo;
		
		Program_Document_Xref__c pdx1 = new Program_Document_Xref__c(
			Document__c = fidDoc.Id,
			Location__c = 'Raleigh',
			Program__c = 'IFCS',
			Service_Line__c = 'Intensive In Home - FCT'
		);
		insert pdx1;
		
		Program_Document_Xref__c pdx2 = new Program_Document_Xref__c(
			Document__c = fidDoc2.Id,
			Location__c = 'Raleigh',
			Program__c = 'IFCS',
			Service_Line__c = 'Intensive In Home - FCT'
		);
		insert pdx2;
		
		ServiceAssignment_Document_JO__c sadjo = new ServiceAssignment_Document_JO__c(
			Service_Assignment__c = ServAssign.Id,
			Document__c = fidDoc.Id,
			File_Status__c = 'Filed'
		);
		insert sadjo;

		ServiceAssignment_Document_JO__c sadjo2 = new ServiceAssignment_Document_JO__c(
			Service_Assignment__c = ServAssign.Id,
			Document__c = fidDoc2.Id,
			File_Status__c = 'Not Filed'
		);
		insert sadjo2;

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
        
        PageReference pageRef = Page.ServiceAssignmentEditNew;
        Test.setCurrentPage(pageRef);
        
        
		System.currentPageReference().getParameters().put('save_new', '1');
		
		List<RecordType> myRecType2 = [select Name from RecordType where (DeveloperName='Assessment_Only') and (SobjectType='Service_Assignment__c') Limit 1];
		String sARecordType2;
		for(RecordType r : myRecType2) {
			sARecordType2 = r.Name;
		}		
		
		System.currentPageReference().getParameters().put('recordType', sARecordType2);
		System.currentPageReference().getParameters().put('id', ServAssign.Id);
		System.currentPageReference().getParameters().put('admissionId', Adm.Id);
		//ServiceAssignmentController2 controller = new ServiceAssignmentController2();
		ApexPages.StandardController sc = new ApexPages.StandardController( ServAssign );
		ServiceAssignmentExt controller = new ServiceAssignmentExt( sc );
		
		controller.LoadData(ServAssign);
		controller.getContractsAndXrefs();
//		controller.CancelServAssignEditNew();
//		controller.EditServAssign();
		controller.loadAvailableCodes();
		controller.saveContractSelections();
		controller.changeToProgramLocationServiceLine();
		controller.getMyLocations();
		controller.getMyPrograms();
		controller.getMyServiceLines();
		controller.getCurrentCodes();
		controller.SelectedCodeID = servCode.Id;
		controller.RemoveCode();
		controller.AddCode();
		controller.theServAssign = ServAssign;
		controller.saveServiceCodeSelections();
		controller.loadProgramDocXrefs();

		System.currentPageReference().getParameters().put('save_new', '');
		sc = new ApexPages.StandardController( ServAssign );
		controller = new ServiceAssignmentExt( sc );

    }
    
}