@isTest
private class ServiceAssignmentExtTest {
    static Service_Assignment__c ServAssign;
    static User usr;
    static Admission__c Adm;
    private static Action_Plan__c testplan;
    private static Action_Plan_Goal__c testGoal;
    public static Action_Plan_Objective__c testObjective;

    static testMethod void myUnitTest() {

        CreateObjects();


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
//      controller.CancelServAssignEditNew();
//      controller.EditServAssign();
        controller.loadAvailableCodes();
        controller.saveContractSelections();
        controller.showAddLocation();
//      controller.changeToProgramLocationServiceLine();
//      controller.getMyLocations();
        controller.getMyPrograms();

        ServAssign.Model__c = 'FCT';
        controller.changeToModel();
        System.Assert( ServAssign.Program__c == 'IFCS');

//      controller.getMyServiceLines();
        controller.getCurrentCodes();
        controller.SelectedCodeID = servCode.Id;
        controller.RemoveCode();
        controller.AddCode();
        controller.theServAssign = ServAssign;
        controller.saveServiceCodeSelections();
        controller.loadProgramDocXrefs();
        controller.setEffectiveDate();

        //controller.addNurAssessment();
        //system.assertEquals(1,Controller.evaluations.size());

        system.assert(!controller.showWorksheetBlocks);
        System.Assert( controller.canCreateWorksheet);

        System.currentPageReference().getParameters().put('save_new', '');
        sc = new ApexPages.StandardController( ServAssign );
        controller = new ServiceAssignmentExt( sc );

        PageReference planpg = controller.NewPlan();

    }

    public testmethod static void saveEdit(){
        CreateObjects();
        ApexPages.StandardController sc = new ApexPages.StandardController( ServAssign );
        ServiceAssignmentExt controller = new ServiceAssignmentExt( sc );

        ServAssign.Program__c = 'test program';

        controller.SaveServAssign();


    }

//    public testmethod static void showShiftAssessment(){
//    	CreateObjects();
//    	ApexPages.StandardController sc = new ApexPages.StandardController( ServAssign );
//        ServiceAssignmentExt controller = new ServiceAssignmentExt( sc );
//        controller.showAddevaluation();
//        controller.evaluation.Shift_Start_time__c = system.Now();
//        controller.evaluation.Shift_End_time__c = system.now().addminutes(30);
//        controller.saveEvaluation();
//        List<Evaluation__c> shiftAsmts = [SELECT Id, NAME FROM Evaluation__c WHERE ServiceAssignment__c =:ServAssign.Id AND RecordType.Name = 'CMShiftAssessment'];
//        system.assertEquals(1,shiftAsmts.size());

//    }

    public testmethod static void showWorksheetBlocks(){
        User tester = Referral_createTestData.createTestUser('astest', 'astest@test.com',  'Action', 'Summary', 'Redwood');
        System.runAs(tester){
            CreateObjects();
            CreateActionObjects();

            ApexPages.StandardController sc = new ApexPages.StandardController( ServAssign );
            ServiceAssignmentExt controller = new ServiceAssignmentExt( sc );

            List<Action_Plan__c> plans = controller.getplans();
            system.assertequals(testplan.id, plans[0].id, 'expected plan not found');
            plans = controller.getActivePlan();
            system.assertequals(testplan.id, plans[0].id, 'expected plan not found');

            system.assert(controller.showWorksheetBlocks);

            List<ServiceAssignmentExt.myDate> skilldates = controller.getuncheckedWeeks();

            system.assertNotEquals(null, skilldates, 'Skilldates is null');
            system.assert(0 < skilldates.size(), 'skilldates has no dates');
            controller.worksheetStartDate = skilldates[0].ParsableDate;
            system.assertnotequals(null,controller.newSkillWorksheet(), 'new skillworksheet failed');
            Action_Plan_Worksheet__c wksh = [select id
                                               from Action_Plan_Worksheet__c
                                              where Start_date__c = :Date.Parse(skilldates[0].parsableDate)
                                                and Action_plan__c = :testplan.id
                                                and RecordType.Name = 'Weekly Skill Result'];
            system.assertnotequals(null, wksh, 'skill worksheet not created');


            List<ServiceAssignmentExt.myDate> behaviordates = controller.getBehaviorMonthsAvailable();

            system.assertNotEquals(null, behaviordates, 'behaviordates is null');
            system.assert(0 < behaviordates.size(), 'behaviordates has no dates');

            controller.worksheetStartDate = behaviordates[0].ParsableDate;
            system.assertnotequals(null,controller.newBehaviorWorksheet(), 'new behavior worksheet failed');
            Action_Plan_Worksheet__c wksh2 = [select id
                                               from Action_Plan_Worksheet__c
                                              where Start_date__c = :Date.Parse(behaviordates[0].parsableDate)
                                                and Action_plan__c = :testplan.id
                                                and RecordType.Name = 'Monthly Behavior Result'];
            system.assertnotequals(null, wksh2, 'behavior worksheet not created');
            List<Action_Plan_Worksheet__c>  apSW = controller.SkillWorksheets;
            List<Action_Plan_Worksheet__c>  apBW = controller.BehaviorWorksheets;

        }
    }

    public testmethod static void showDiagnosis(){
        User tester = Referral_createTestData.createTestUser('astest', 'astest@test.com',  'Action', 'Summary', 'Redwood');
        System.runAs(tester){
            CreateObjects();
            ApexPages.StandardController sc = new ApexPages.StandardController( ServAssign );
            ServiceAssignmentExt controller = new ServiceAssignmentExt( sc );

            ICD__c icd = new ICD__c(Code_Type__c = 'ICD-10', Icd_Description__c = 'testing'); insert icd;
            Diagnosis__c diag = new Diagnosis__c(Status__c = 'Active',
                                                 Type__c = 'Admission',
                                                 PBS__c  = ServAssign.Person_Being_Served__c,
                                                 ICD__c = icd.Id);
            insert diag;
            ServiceAssignment_Diagnosis_JO__c asdiag = new ServiceAssignment_Diagnosis_JO__c(Service_Assignment__c = ServAssign.Id,
                                                                                             Diagnosis__c = diag.Id,
                                                                                             Ranking__c = 'Secondary');
            insert asdiag;
            controller.showAddsadiagJo();
            controller.savesadiagJo();
            system.assert(controller.sadiagJOList.size() == 1);

            ApexPages.currentPage().getParameters().put('sadiagJOId',asdiag.Id);
            controller.showEditsadiagJo();
            List<SelectOption> diagList = controller.pbsDiagnosisList;

            Service_Assignment__c dummy  = controller.dummy;
            controller.gotoAdmissionEditPage();
            controller.gototServAssignViewPage();
            controller.checkFullyDischarge();
            list<Selectoption> mVal = controller.modelValues;
            controller.getStatusValues();

            list<SelectOption> endSV = controller.endOfServiceCsValues;
            controller.loadProgramList();
            controller.changeToProgramLocationServiceLine();
            string str = controller.theProgram;
            controller.getMyLocations();
            controller.getMyServiceLines();
            controller.addServAssignClose();
            controller.EditServAssign();
            controller.getNotes();
            string showsaClsid = controller.showServAssignCloseEditId;
            string saClsid = controller.servAssignCloseEditId;
            String selPgm  = controller.SelectedProgram;
            String selServL = controller.SelectedServiceLine;
            ID seljoId = controller.SelectedJoID;
            Integer phsToSav = controller.phaseToSave;
            List<ServiceAssignment_Document_JO__c> sadjos  = controller.sadjos;

            Test.startTest();
            Boolean hasFidDocs = controller.hasFidDocs;
            Boolean episodeReq = controller.episodeReq;
            Assessment__c asmt = new Assessment__c (type__c = 'FAD Summary', Status__c = 'Open', Admission__c = ServAssign.Admission__c, Service_Assignment__c = ServAssign.Id);
            insert asmt;
            system.assert(controller.getAssessments_Fad().size() == 1);
            Assessment__c asmtRR = new Assessment__c (type__c = 'Restraint Reduction', Status__c = 'Open', Admission__c = ServAssign.Admission__c, Service_Assignment__c = ServAssign.Id);
            insert asmtRR;
            system.assert(controller.getAssessments_RestraintReduction().size() == 1);
            Service_Assignment_Closure__c saClos = new Service_Assignment_Closure__c(Status__c = 'New', Service_Assignment__c = ServAssign.Id);
            insert saClos;
            system.assert(controller.getServAssignCloses().size() == 1);

            Boolean sCode  = controller.showCodes;
            Boolean showLoc = controller.showLocation;
            boolean shwSACls = controller.showServAssignClose;
            boolean ShNurse = controller.showNurseAssessment;
            controller.createIncident();
            List<Incident__c> incidents = controller.incidents;
            String age = controller.age;
            controller.getSaStrStartDateTime();
            controller.setSaStrStartDateTime('');
            controller.getTherapyList();
            Test.stopTest();


        }
    }

    public testmethod static void remoteActionsavesadiagJORemote(){
        CreateObjects();
        ICD__c icd = new ICD__c(Code_Type__c = 'ICD-10', Icd_Description__c = 'testing'); insert icd;
        Diagnosis__c diag = new Diagnosis__c(Status__c = 'Active',
                                             Type__c = 'Admission',
                                             PBS__c  = ServAssign.Person_Being_Served__c,
                                             ICD__c = icd.Id);
        insert diag;
        ServiceAssignment_Diagnosis_JO__c asdiag = new ServiceAssignment_Diagnosis_JO__c(Service_Assignment__c = ServAssign.Id,
                                                                                         Diagnosis__c = diag.Id,
                                                                                         Ranking__c = 'Secondary');
        insert asdiag;

        ServiceAssignmentExt.checkErrors(ServAssign.id, asdiag.id, diag.id);
        system.assertEquals(true, ServiceAssignmentExt.savesadiagJORemote(asdiag.id, diag.id, ServAssign.id, false, false, '', '', '', '', '', ''));
        ServiceAssignmentExt.checkErrors(ServAssign.id, null, diag.id);
        system.assertEquals(true, ServiceAssignmentExt.savesadiagJORemote('', diag.id, ServAssign.id, false, false, '', '', '', '', '', ''));
    }


    public testmethod static void providerAssociation(){
        User tester = Referral_createTestData.createTestUser('astest', 'astest@test.com',  'Action', 'Summary', 'Redwood');
        System.runAs(tester){
            CreateObjects();
            ApexPages.StandardController sc = new ApexPages.StandardController( ServAssign );
            ServiceAssignmentExt controller = new ServiceAssignmentExt( sc );

            Tmn_Provider__c provider = new Tmn_Provider__c(
                First_Name__c = 'First',
                Last_Name__c = 'Last',
                Gender__c = 'Male'
            );
            insert provider;

            TMN_Provider_Application__c providerApp = new TMN_Provider_Application__c (
                Application_Date__c = date.today(),
                Effective_Date__c = date.today(),
                Expiration_Date__c = date.today().addYears(2),
                Status__c = 'Approved',
                Provider__c = provider.Id
            );
            insert providerApp;

            Service_Assignment_Provider_JO__c provJo = new Service_Assignment_Provider_JO__c (
                Start_Date__c = date.today(),
                End_Date__c = date.today().addYears(1),
                TMN_Provider__c = provider.Id,
                Service_Assignment__c = ServAssign.Id
            );
            insert provJo;

            controller.populateProvList();
            system.assert(controller.provList.size() == 1);
            ApexPages.currentPage().getParameters().put('saProvId',provJo.Id);
            controller.redirect();
        }
    }

    public testmethod static void showAddPersonalAgent(){
        User tester = Referral_createTestData.createTestUser('astest', 'astest@test.com',  'Action', 'Summary', 'Redwood');
        System.runAs(tester){
            CreateObjects();
            Service_Assignment_Personal_Agent__c sapa = new Service_Assignment_Personal_Agent__c(Status__c = 'Active',
                                                                                                 Service_Assignment__c = ServAssign.Id);
            insert sapa;
            ApexPages.StandardController sc = new ApexPages.StandardController( ServAssign );
            ServiceAssignmentExt controller = new ServiceAssignmentExt( sc );
            Service_Assignment_Personal_Agent__c pa = controller.pa;
            controller.showAddpa();
            controller.savePa();
            ApexPages.currentPage().getParameters().put('paId',sapa.Id);
            controller.showEditpa();
            controller.cancelPa();
            controller.showaddCaseManager();
            controller.closecaseManager();
            Date myDate = Date.today();
            String dayString = myDate.format();
            ServiceAssignmentExt.checkPAoverlap(ServAssign.id, sapa.Id, '', dayString,  '');
            ServiceAssignmentExt.checkPAoverlap(ServAssign.id, sapa.Id, '', dayString,  dayString);
            Test.startTest();
            controller.CancelServAssignEditNew();
            List<Evaluation__c> resAsmntss = controller.residentAssessments;
            controller.getshowResAsmt();
            List<Evaluation__c> shtAsmnts = controller.shiftAssessments;
            List<Evaluation__c> cnaWbooks = controller.cnaWorkbooks;
            List<Evaluation__c> resEvents = controller.restraintEvents;
            controller.addResAsmt();
            controller.addrestraintEvent();
            controller.createFadAssess();
            boolean b1 = controller.canCreateNote;
            boolean b2 = controller.canCreateCaseManagementNote;
            Boolean refreshPage = controller.refreshPage;
            Test.stopTest();

        }
    }


    public testmethod static void remoteActionLoadSaveServiceLocation(){
    	       CreateObjects();
            string tmp = String.ValueOf(system.currentTimeMillis());
            Service_Location__c svl = new Service_Location__c(Street__c = '10 Main St.',
            State__c = 'CA',
            Setting__c = 'Residential',
            Service_Value__c = 'IDD',
            Program__c = 'Redwood Res',
            UniqueID__c = '10031' + tmp.Substring(tmp.length()-6, tmp.length()-1),
	        ProgramID__c = '10005',
	        Phone__c = '213-555-5555',
	        FacilityID__c = 20,
	        City__c = 'Bakersfield', Alias__c ='10001'+tmp.Substring(tmp.length()-6,tmp.length()-1));
	        insert svl;

	        Service_Assignment__c sa = new Service_Assignment__c(
            Name = 'TEST SERV ASSIGN',
            Admission__c = Adm.Id,
     //       Person_Being_Served__c = aContactId,
            Start_Date__c = date.newInstance(2013, 1, 1),
            Status__c = 'Active',
            Program__c = 'IFCS',
            Service_Line__c = 'Intensive In Home - FCT'
	        );
	        insert sa;
	        system.assertEquals('CA' , ServiceAssignmentExt.loadServiceLocation(svl.id).State__c);
            system.assertEquals(true, ServiceAssignmentExt.saveServiceLocation(sa.id, svl.id));
    }

	public testmethod static void showFundingSources(){
        User tester = Referral_createTestData.createTestUser('astest', 'astest@test.com',  'Action', 'Summary', 'Care Meridian');
        System.runAs(tester){
			CreateObjects();
			ApexPages.StandardController sc = new ApexPages.StandardController( ServAssign );
			ServiceAssignmentExt controller = new ServiceAssignmentExt( sc );
			controller.showAddFundingSource();
			controller.fundingSource.Service_Assignment__c = ServAssign.Id;
			controller.fundingSource.RecordtypeId =  Utility.getRecordTypeForFundingSource('CareMeridian');
			controller.saveFundingSource();
			//controller.showAddFundingSource();
			//controller.saveFundingSource();
			controller.fundingSource = controller.fundingSources.get(0);
			controller.showEditFundingSource();
			controller.saveFundingSource();
			system.assert(controller.fundingSources.size() == 1, 'No funding sources');
            boolean b1 = controller.canCreateFundingSource;
            boolean b2 = controller.canEditFundingSource;
            boolean b3 = controller.canViewFundingSource;
		}
    }

    public testmethod static void showFundingSourcesNeuro(){
        User tester = Referral_createTestData.createTestUser('astest', 'astest@test.com',  'Action', 'Summary', 'NeuroRestorative');
        System.runAs(tester){
			CreateObjects();
			ApexPages.StandardController sc = new ApexPages.StandardController( ServAssign );
			ServiceAssignmentExt controller = new ServiceAssignmentExt( sc );
			controller.getfundingsourceRecordType();
			controller.showAddFundingSource();
			controller.fundingSource.Service_Assignment__c = ServAssign.Id;
			controller.fundingSource.RecordtypeId =  Utility.getRecordTypeForFundingSource('NeuroRestorative');
			controller.saveFundingSource();
			controller.populateFundingSources();
			controller.fundingSource = controller.fundingSources.get(0);
			controller.showEditFundingSource();
			controller.finalizeFundingSource();
			controller.fundingSource = controller.fundingSources.get(0);
			controller.showEditFundingSource();
			controller.inactivateFundingSource();
			controller.fundingSource = controller.fundingSources.get(0);
			system.assert(controller.fundingSource.Funding_Source_Status__c == 'Inactive',controller.fundingSource.Funding_Source_Status__c);

		}
    }



    private static void CreateObjects(){
        // Get System Admin profile ID.
        String ProfileId = [select ProfileId from User where (Profile.Name='System Administrator') LIMIT 1].ProfileId;

        usr = new User(USERNAME='test@thementornetwork.com',
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
            PersonMailingStateCode='AZ',
            PersonEmail='test@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678'
        );
        insert Accnt;

        List<Account> testAcct = [Select Id, PersonContactId From Account a WHERE a.Id = :Accnt.Id];
        System.Debug('What is in testAcct: ' + testAcct);
        Id aContactId = testAcct[0].PersonContactId;
        Id aAccountId = testAcct[0].Id;

        Adm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = aContactId,
            Admission_Effective_DateTime__c = datetime.newInstance(2013, 1, 1, 13, 0, 0),
            Status__c = 'Active',
            State__c = 'NC'
        );
        insert Adm;

        string tmp = String.ValueOf(system.currentTimeMillis());
        Service_Location__c svl = new Service_Location__c(Street__c = '10 Main St.',
          State__c = 'CA',
          Setting__c = 'Residential',
          Service_Value__c = 'IDD',
          Program__c = 'Redwood Res',
          UniqueID__c = '10031' + tmp.Substring(tmp.length()-6, tmp.length()-1),
          ProgramID__c = '10005',
          Phone__c = '213-555-5555',
          FacilityID__c = 20,
          City__c = 'Bakersfield', Alias__c ='10001'+tmp.Substring(tmp.length()-6,tmp.length()-1));

          insert svl;


        ServAssign = new Service_Assignment__c(
            Name = 'TEST SERV ASSIGN',
            Admission__c = Adm.Id,
            Person_Being_Served__c = aContactId,
            Start_Date__c = date.newInstance(2013, 1, 1),
            Status__c = 'Active',
            Program__c = 'IFCS',
            Service_Line__c = 'Intensive In Home - FCT',
            Service_Location__c = svl.id
        );
        insert ServAssign;


    }
    private static void CreateActionObjects(){
        testplan = new Action_Plan__c();
        testplan.Service_Assignment__c = ServAssign.id;
        testplan.effective_date__c = date.newInstance(2013, 1, 1);
        testplan.target_date__c = testplan.effective_date__c.addmonths(3);
        testplan.Status__c = 'Active Final';
        insert testPlan;

        testGoal = new Action_Plan_Goal__c();
        testGoal.Action_Plan__c = testPlan.Id;
        testGoal.Description__c = 'Just a testobject';
        insert testGoal;

        testObjective = new Action_Plan_Objective__c();
        testObjective.Action_Plan_Goal__c = testGoal.Id;
        testObjective.Description__c = 'Just a testobject';
        testObjective.Status__c = 'In Progress';
        testObjective.Type__c = 'Skill';
        testObjective.Effective_date__c = date.newInstance(2013, 1, 1);
        testObjective.Target_end_date__c = date.newInstance(2013, 2, 1);
        insert testObjective;

    }

    public testmethod static void remoteActionfindDuplicateSeizure(){
        CreateObjects();
        Datetime stEndTime = DateTime.newInstance(2013, 1,1,0,0,0);
        Seizure__c seizure = new Seizure__c();
        seizure.Start_DateTime__c = stEndTime;
        seizure.End_DateTime__c = DateTime.newInstance(2013, 1,2,0,0,0);
        seizure.Service_Assignment__c = ServAssign.Id;
        insert seizure;
        System.assertequals(false, ServiceAssignmentExt.findDuplicateSeizure(
                                    stEndTime.addHours(1).format(),
                                       stEndTime.addDays(1).format(),
                                       Id.valueOf(ServAssign.Id),
                                       Id.valueOf(seizure.id) ) );
        System.assertequals(true, ServiceAssignmentExt.findDuplicateSeizure(
                                       stEndTime.addHours(1).format(),
                                       stEndTime.addDays(1).format(),
                                       Id.valueOf(ServAssign.Id),
                                       null) );
    }

    public testmethod static void saveAndEditSeizure(){
        CreateObjects();

        ApexPages.StandardController sc = new ApexPages.StandardController( ServAssign );
        ServiceAssignmentExt controller = new ServiceAssignmentExt( sc );
        controller.seizureStart_DateTime = '11/16/2014 13:00:55';
        controller.seizureEnd_DateTime = '11/17/2014 13:00:55';
        controller.saveSeizure();
        System.assertequals(1, [select id from Seizure__c].size());

        PageReference pageRef = Page.SeizureEdit;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('seizureId', [select id from Seizure__c].get(0).id);
        controller.showEditSeizure();
        controller.newSeizure();
    }

}