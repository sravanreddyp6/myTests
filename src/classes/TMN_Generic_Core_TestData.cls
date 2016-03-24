public without sharing class TMN_Generic_Core_TestData {

	public account theAccount {get; set;}
	public Admission__c theAdm {get; set;}
	public ID contactID {get; set;}
	public Service_Assignment__c theSA {get; set;}
	public Service_Code__c theServiceCode {get; set;}

	public TMN_Generic_Core_TestData (){

		loadData('AZ');

	}
	public void loadData(string myState){
		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);

		String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') LIMIT 1].Id;
		theAccount = new Account(
				RecordTypeID=RecTypeId,
				FirstName= 'FName' + h.substring(0,5),
				LastName='LName'+ h.substring(0,5),
				PersonMailingStreet='123 Test Street',
				PersonMailingPostalCode='12345',
				PersonMailingCity='SFO',
				PersonMailingStateCode= myState,
				PersonEmail='test@yahoo.com',
				PersonHomePhone='12345678',
				PersonMobilePhone='12345678',
				Other_ID__pc = '12345-111',
				Other_ID_description__pc = 'other Id'
				);
		insert theAccount;

		List<Account> testAcct = [Select Id, PersonContactId From Account a WHERE a.Id = :theAccount.Id];
		contactID = testAcct[0].PersonContactId;
		Id aAccountId = testAcct[0].Id;

		theAdm = new Admission__c(
				Name = 'TEST ADM',
				Person_Being_Served__c = contactID,
				Admission_Effective_DateTime__c = datetime.newInstance(2013, 1, 1, 0, 0, 0),
				//Discharged_Date__c = date.today(),
				//Status__c = 'Discharged',
				//Discharged_Status__c = 'Positive',
				//Reason_for_Discharge__c = 'TEST REASON FOR DISCHARGE',
				Network_Offering__c = 'ARY',
				state__c = mystate
				);
		insert theAdm;
		 
		 
		Alias__c ali = new Alias__c ( alias_unique__c = generateRandomString(6),
										alias_business_unit__c = 'BU 370 REM South Central, Inc',
										alias_level__c = '',
										alias_parent__c = 'MN-AD44', 
										name = generateRandomString(6), 
										alias_operating_group__c = 'Redwood', 
										alias_state__c= mystate,
										alias_description__c = 'MN-REMSCS-SL-Chrysalis-MH',
										alias_region__c = 'Redwood North',
										alias_responsibility_center_code__c = '79647',
										alias_service_line__c = 'Waiver Group Homes');
		insert ali;
		
		 
		Service_Location__c sl = new Service_Location__c(
				Alias_Lookup__c = ali.id,
				Alias__c = '370647',
				City__c = 'Redwood Falls',
				FacilityID__c = 13.0,
				Name = '370647',
				ProgramID__c = '370647000',
				Program__c = 'MN-REMSCS-SL-Chrysalis-MH',
				Service_Value__c = 'IDD - Residential Group Home',
				Setting__c = 'Inpatient/Residential',
				Source_System__c = 'AVATAR',
				State__c = 'MN',
				Status__c = 'Active',
				Street__c = '515 E Elm Street',
				TIN__c = '41-1509578',
				ZIP__c = '56283-1119',
				TMN_Scope__c = 'Residential',
				UniqueID__c = generateRandomString(10)  // This needs to be unique
				);
		insert sl;
		theSA = new Service_Assignment__c(
				phase_1_Start_Date__c = system.today().addDays(-7),
				Admission__c = theAdm.id,
				Person_Being_served__c = contactID,
				Program__c = 'IFCS',
				Status__c = 'Active',
				SA_Start_DateTime__c = datetime.newInstance(2013, 1, 1, 0, 0, 0),
				start_date__c = date.newInstance(2013,1,1),
				Projected_Treatment_End_Date__c = date.newInstance(2014, 12, 31),
				Service_Location__c = sl.Id
				);

		System.debug([SELECT service_location__r.id, service_location__r.Alias__c, service_location__r.program__c
					  FROM service_assignment__c]);
		System.debug([SELECT service_location__r.id slID, service_location__r.Alias__c alias, service_location__r.program__c prgm
					  FROM service_assignment__c
						GROUP BY service_location__r.id, service_location__r.program__c, service_location__r.Alias__c
						HAVING COUNT(service_location__r.id) > 0
						ORDER BY service_location__r.program__c]);

		insert theSA;


		theServiceCode = new Service_Code__c(
				Service_Code__c = '10942.1161',
				FacilityID__c = 'TEST FAC ID',
				Program_Code__c = 'TEST PROGRAM CODE'+h.substring(0,10),
				Program_Value__c = 'TEST PROGRAM VALUE',
				Start_Date__c = date.newInstance(2000, 1, 1),
				state__c = 'IN'
				);
		insert theServiceCode;

	}
	public static String generateRandomString(Integer len) {
		final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
		String randStr = '';
		while (randStr.length() < len) {
			Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
			randStr += chars.substring(idx, idx+1);
		}
		return randStr;
	}

	public static Service_Assignment_Closure__c createServiceAssignmentClosure(Service_Assignment__c sa) {
		Service_Assignment_Closure__c thisServiceAssignmentClosure = new Service_Assignment_Closure__c(Service_Assignment__c = sa.Id);
		insert thisServiceAssignmentClosure;
		Service_Assignment_Closure__c testServiceAssignmentClosure = [ SELECT Id, Service_Assignment__c
		                                                               FROM Service_Assignment_Closure__c
		                                                               WHERE Id = :thisServiceAssignmentClosure.Id];
		return testServiceAssignmentClosure;
	}


	public static Assessment__c createAssessment(Admission__c adm, Service_Assignment__c sa, String type, String status, String phase, Boolean disregard) {
		Assessment__c thisAssessment = new Assessment__c(Admission__c = adm.Id, Service_Assignment__c = sa.Id, Type__c = type, Status__c = status, Phase__c = phase, Disregard__c = disregard);
		if(type == 'CANS' || type == 'RISK'){
			assessment_type__c tmpType = new assessment_type__c (name = type);
			insert tmpType;
			thisAssessment.assessment_type__c = tmpType.id;
		}
		thisAssessment.Assessment_Date__c = system.today();
		thisAssessment.TFC_Family_Vistas__c = 'Yes';
		thisAssessment.Interval__c = 'Intake';
		insert thisAssessment;
		Assessment__c testAssessment = [ SELECT Id, Service_Assignment__c,Admission__c, Type__c, Status__c, Phase__c, Assessment_Type__c, Assessment_Type__r.name,  Disregard__c FROM Assessment__c WHERE Id = :thisAssessment.Id ];
		return testAssessment;
	}


	public static User createUser(string profileName,string userAlias, string userName, string firstName, string lastName, string OperatingGroup){
		Map<String,Profile> profileMap = new Map<String,Profile>();
		List<Profile> proflist = [SELECT Id, Name FROM Profile];
		for(Profile p : proflist){
			profileMap.put(p.Name, P);
		}
		User testUser = new User(
			alias = userAlias,
			email='testuser@TMN.com',
			emailencodingkey='UTF-8',
			lastname=lastName,firstname=firstName, languagelocalekey='en_US',
			localesidkey='en_US',
			profileid = profileMap.get(profileName).id,
			timezonesidkey='America/Los_Angeles',
			username=username + System.currentTimeMillis(),
			operating_group__c=OperatingGroup  // to overcome trigger that doesn't run during test
		);

		insert testUser;

		Tmn_User__c tmnUser= new Tmn_User__c(operating_group__c=OperatingGroup, Salesforce_User_Account__c=testUser.id);
		insert tmnUser;
		return testUser;
	}

	public static User createUserWithRole(string profileName,string userAlias, string userName, string firstName, string lastName, string OperatingGroup, string roleName){
		Map<String,Profile> profileMap = new Map<String,Profile>();
		List<Profile> proflist = [SELECT Id, Name FROM Profile];
		for(Profile p : proflist){
			profileMap.put(p.Name, P);
		}
		
		ID roleId;
		List<UserRole> urole = [ select id from UserRole where developername = :roleName ];
		if ( urole.size() > 0)
			roleId = urole[0].Id;
		else
			roleId = null;
		
		User testUser = new User(
			alias = userAlias,
			email='testuser@TMN.com',
			emailencodingkey='UTF-8',
			lastname=lastName,firstname=firstName, languagelocalekey='en_US',
			localesidkey='en_US',
			profileid = profileMap.get(profileName).id,
			timezonesidkey='America/Los_Angeles',
			username=username + System.currentTimeMillis(),
			operating_group__c=OperatingGroup,  // to overcome trigger that doesn't run during test
			userroleid = roleId
		);

		insert testUser;

		Tmn_User__c tmnUser= new Tmn_User__c(operating_group__c=OperatingGroup, Salesforce_User_Account__c=testUser.id);
		insert tmnUser;
		return testUser;
	}
	
	public static void permsetAssign(string[]permSets, Id assigntoId){
		List<PermissionSet> theSets = [SELECT ID, Name FROM PermissionSet WHERE Name IN :permSets];
		List<PermissionSetAssignment> thepermAssigns = new List<PermissionSetAssignment>();
		for(PermissionSet ps : theSets){
			thepermAssigns.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = assigntoId));

		}
		insert thepermAssigns;

	}

	public static Progress_Note__c createProgressNote(Service_Assignment__c sa, Admission__c adm, Service_Code__c sc, String contactId, Datetime startDateTime, Datetime endDateTime) {
		Progress_Note__c thisProgressNote = new Progress_Note__c(Service_Assignment__c = sa.Id,
				Service_Code__c = sc.Id,
				Admission__c = adm.ID,
				Start_Time__c = startDateTime,
				End_Time__c = endDateTime,
				Person_Being_Served__c = contactId,
				No_Approval_Needed__c = true,
				Approval_Status__c = 'Approved',
				Status__c = 'Final');
		insert thisProgressNote;
		Progress_Note__c testProgressNote = [ SELECT Id, Service_Assignment__c, Person_Being_Served__c FROM Progress_Note__c WHERE Id = :thisProgressNote.Id ];
		return testProgressNote;
	}

    private static list<Eval__c> testEvals;
    public static list<Eval__c> getEvalTestRecords() {
    	if (testEvals == null || testEvals.size() == 0)  createEvalTestRecords();
    	return testEvals;
    }
    private static void createEvalTestRecords() {
    	testEvals = new list<Eval__c>();

        //create Eval_Type__c records
        list<Eval_Type__c> evlTyps = new list<Eval_Type__c>();
        evlTyps.add(new Eval_Type__c(Name = 'Residential', Category__c = 'Care Meridian', External_Eval_Type_ID__c = 1));
        evlTyps.add(new Eval_Type__c(Name = 'Head to Toe', Category__c = 'Care Meridian', External_Eval_Type_ID__c = 2));
        evlTyps.add(new Eval_Type__c(Name = 'CNA Workbook', Category__c = 'Care Meridian', External_Eval_Type_ID__c = 3));
        evlTyps.add(new Eval_Type__c(Name = 'Restraint Event', Category__c = 'Care Meridian', External_Eval_Type_ID__c = 4));
        insert evlTyps;

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'Skin/Body',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'Wound Detail',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'IsValid',
        htmlid__c = 'IsValid',
        Field_Type__c = 'Hidden',
        Field_Sub_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('0.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'Skin/Body',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'Wound Detail',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'isRepeatable',
        htmlid__c = 'isRepeatable',
        visible__c = false,
        Field_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('99.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'IsValid',
        htmlid__c = 'IsValid',
        Field_Type__c = 'Hidden',
        Field_Sub_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('0.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'isRepeatable',
        htmlid__c = 'isRepeatable',
        visible__c = false,
        Field_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('99.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c='ErrorMsg',
        htmlid__c='ErrorMsg',
        Field_Type__c='Hidden',
        Field_Sub_Type__c='String',
        Field_Sequence__c=Decimal.valueOf('0.10')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Boolean_Checkbox',
        htmlid__c = 'Boolean_Checkbox',
        Field_Type__c = 'Boolean',
        Field_Sub_Type__c = 'Checkbox',
        Field_Sequence__c = Decimal.valueOf('1.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = true,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Boolean_Dropdown',
        htmlid__c = 'Boolean_Dropdown',
        Field_Type__c = 'Boolean',
        Field_Sub_Type__c = 'Dropdown',
        Field_Sequence__c = Decimal.valueOf('2.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        length__c = 3000,
        Field_Name__c = 'String_3000',
        htmlid__c = 'String_3000',
        Field_Type__c = 'String',
        Field_Sequence__c = Decimal.valueOf('3.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'String_300',
        htmlid__c = 'String_300',
        Field_Type__c = 'String',
        Field_Sequence__c = Decimal.valueOf('3.1')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Double',
        htmlid__c = 'Double',
        Field_Type__c = 'Double',
        Field_Sequence__c = Decimal.valueOf('4.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Int',
        htmlid__c = 'Int',
        Field_Type__c = 'Int',
        Field_Sequence__c = Decimal.valueOf('5.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'DropDown',
        htmlid__c = 'DropDown',
        Field_Type__c = 'DropDown',
        Field_Sequence__c = Decimal.valueOf('6.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Date',
        htmlid__c = 'Date',
        Field_Type__c = 'Date',
        Field_Sequence__c = Decimal.valueOf('7.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Datetime',
        htmlid__c = 'Datetime',
        Field_Type__c = 'Datetime',
        Field_Sequence__c = Decimal.valueOf('8.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = true,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Multiselect_Checkbox',
        htmlid__c = 'Multiselect_Checkbox',
        Field_Type__c = 'Multiselect',
        Field_Sub_Type__c = 'Checkbox',
        Field_Sequence__c = Decimal.valueOf('9.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Multiselect',
        htmlid__c = 'Multiselect',
        Field_Type__c = 'Multiselect',
        Field_Sequence__c = Decimal.valueOf('10.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'BodyMap',
        htmlid__c = 'BodyMap',
        Field_Type__c = 'BodyMap',
        Field_Sequence__c = Decimal.valueOf('11.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Image',
        htmlid__c = 'Image',
        Field_Type__c = 'Image',
        field_sub_type__c= 'Image',
        Field_Sequence__c = Decimal.valueOf('12.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[0].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Slider',
        htmlid__c = 'Slider',
        Field_Type__c = 'Slider',
        Field_Sequence__c = Decimal.valueOf('10.0')));



        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'Skin/Body',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'Wound Detail',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'IsValid',
        htmlid__c = 'IsValid',
        Field_Type__c = 'Hidden',
        Field_Sub_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('0.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'Skin/Body',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'Wound Detail',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'isRepeatable',
        htmlid__c = 'isRepeatable',
        visible__c = false,
        Field_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('99.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'isRepeatable',
        htmlid__c = 'isRepeatable',
        visible__c = false,
        Field_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('99.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'IsValid',
        htmlid__c = 'IsValid',
        Field_Type__c = 'Hidden',
        Field_Sub_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('0.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c='ErrorMsg',
        htmlid__c='ErrorMsg',
        Field_Type__c='Hidden',
        Field_Sub_Type__c='String',
        Field_Sequence__c=Decimal.valueOf('0.10')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Boolean_Checkbox',
        htmlid__c = 'Boolean_Checkbox',
        Field_Type__c = 'Boolean',
        Field_Sub_Type__c = 'Checkbox',
        Field_Sequence__c = Decimal.valueOf('1.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = true,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Boolean_Dropdown',
        htmlid__c = 'Boolean_Dropdown',
        Field_Type__c = 'Boolean',
        Field_Sub_Type__c = 'Dropdown',
        Field_Sequence__c = Decimal.valueOf('2.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        length__c = 3000,
        Field_Name__c = 'String_3000',
        htmlid__c = 'String_3000',
        Field_Type__c = 'String',
        Field_Sequence__c = Decimal.valueOf('3.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'String_300',
        htmlid__c = 'String_300',
        Field_Type__c = 'String',
        Field_Sequence__c = Decimal.valueOf('3.1')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Double',
        htmlid__c = 'Double',
        Field_Type__c = 'Double',
        Field_Sequence__c = Decimal.valueOf('4.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Int',
        htmlid__c = 'Int',
        Field_Type__c = 'Int',
        Field_Sequence__c = Decimal.valueOf('5.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'DropDown',
        htmlid__c = 'DropDown',
        Field_Type__c = 'DropDown',
        Field_Sequence__c = Decimal.valueOf('6.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Date',
        htmlid__c = 'Date',
        Field_Type__c = 'Date',
        Field_Sequence__c = Decimal.valueOf('7.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Datetime',
        htmlid__c = 'Datetime',
        Field_Type__c = 'Datetime',
        Field_Sequence__c = Decimal.valueOf('8.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = true,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Multiselect_Checkbox',
        htmlid__c = 'Multiselect_Checkbox',
        Field_Type__c = 'Multiselect',
        Field_Sub_Type__c = 'Checkbox',
        Field_Sequence__c = Decimal.valueOf('9.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Multiselect',
        htmlid__c = 'Multiselect',
        Field_Type__c = 'Multiselect',
        Field_Sequence__c = Decimal.valueOf('10.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'BodyMap',
        htmlid__c = 'BodyMap',
        Field_Type__c = 'BodyMap',
        Field_Sequence__c = Decimal.valueOf('11.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Image',
        htmlid__c = 'Image',
        Field_Type__c = 'Image',
        field_sub_type__c= 'Image',
        Field_Sequence__c = Decimal.valueOf('12.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[1].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Slider',
        htmlid__c = 'Slider',
        Field_Type__c = 'Slider',
        Field_Sequence__c = Decimal.valueOf('10.0')));


 	// CNA Workbook
        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'Skin/Body',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'Wound Detail',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'IsValid',
        htmlid__c = 'IsValid',
        Field_Type__c = 'Hidden',
        Field_Sub_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('0.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'Skin/Body',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'Wound Detail',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'isRepeatable',
        htmlid__c = 'isRepeatable',
        visible__c = false,
        Field_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('99.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'isRepeatable',
        htmlid__c = 'isRepeatable',
        visible__c = false,
        Field_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('99.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'IsValid',
        htmlid__c = 'IsValid',
        Field_Type__c = 'Hidden',
        Field_Sub_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('0.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c='ErrorMsg',
        htmlid__c='ErrorMsg',
        Field_Type__c='Hidden',
        Field_Sub_Type__c='String',
        Field_Sequence__c=Decimal.valueOf('0.10')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Boolean_Checkbox',
        htmlid__c = 'Boolean_Checkbox',
        Field_Type__c = 'Boolean',
        Field_Sub_Type__c = 'Checkbox',
        Field_Sequence__c = Decimal.valueOf('1.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = true,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Boolean_Dropdown',
        htmlid__c = 'Boolean_Dropdown',
        Field_Type__c = 'Boolean',
        Field_Sub_Type__c = 'Dropdown',
        Field_Sequence__c = Decimal.valueOf('2.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        length__c = 3000,
        Field_Name__c = 'String_3000',
        htmlid__c = 'String_3000',
        Field_Type__c = 'String',
        Field_Sequence__c = Decimal.valueOf('3.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'String_300',
        htmlid__c = 'String_300',
        Field_Type__c = 'String',
        Field_Sequence__c = Decimal.valueOf('3.1')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Double',
        htmlid__c = 'Double',
        Field_Type__c = 'Double',
        Field_Sequence__c = Decimal.valueOf('4.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Int',
        htmlid__c = 'Int',
        Field_Type__c = 'Int',
        Field_Sequence__c = Decimal.valueOf('5.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'DropDown',
        htmlid__c = 'DropDown',
        Field_Type__c = 'DropDown',
        Field_Sequence__c = Decimal.valueOf('6.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Date',
        htmlid__c = 'Date',
        Field_Type__c = 'Date',
        Field_Sequence__c = Decimal.valueOf('7.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Datetime',
        htmlid__c = 'Datetime',
        Field_Type__c = 'Datetime',
        Field_Sequence__c = Decimal.valueOf('8.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = true,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Multiselect_Checkbox',
        htmlid__c = 'Multiselect_Checkbox',
        Field_Type__c = 'Multiselect',
        Field_Sub_Type__c = 'Checkbox',
        Field_Sequence__c = Decimal.valueOf('9.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Multiselect',
        htmlid__c = 'Multiselect',
        Field_Type__c = 'Multiselect',
        Field_Sequence__c = Decimal.valueOf('10.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'BodyMap',
        htmlid__c = 'BodyMap',
        Field_Type__c = 'BodyMap',
        Field_Sequence__c = Decimal.valueOf('11.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Image',
        htmlid__c = 'Image',
        Field_Type__c = 'Image',
        field_sub_type__c= 'Image',
        Field_Sequence__c = Decimal.valueOf('12.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Slider',
        htmlid__c = 'Slider',
        Field_Type__c = 'Slider',
        Field_Sequence__c = Decimal.valueOf('10.0')));


        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'Turns',
        Category_Sequence__c = 3,
        Cat_Seq_Text__c = '3',
        Sub_Category__c = 'Details',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'IsValid',
        htmlid__c = 'IsValid',
        Field_Type__c = 'Hidden',
        Field_Sub_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('0.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'Turns',
        Category_Sequence__c = 3,
        Cat_Seq_Text__c = '3',
        Sub_Category__c = 'Details',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'start date/time',
        htmlid__c = 'startDate',
        Field_Type__c = 'DateTime',
        field_sub_type__c= '',
        Field_Sequence__c = Decimal.valueOf('1.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'Turns',
        Category_Sequence__c = 3,
        Cat_Seq_Text__c = '3',
        Sub_Category__c = 'Details',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'end date/time',
        htmlid__c = 'endDate',
        Field_Type__c = 'DateTime',
        field_sub_type__c= '',
        Field_Sequence__c = Decimal.valueOf('1.1')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'Turns',
        Category_Sequence__c = 3,
        Cat_Seq_Text__c = '3',
        Sub_Category__c = 'Details',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'positioning',
        htmlid__c = 'position',
        Field_Type__c = 'String',
        field_sub_type__c= '',
        length__c = 200,
        Field_Sequence__c = Decimal.valueOf('1.0')));



        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[2].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 2,
        Cat_Seq_Text__c = '2',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Slider',
        htmlid__c = 'Slider',
        Field_Type__c = 'Slider',
        Field_Sequence__c = Decimal.valueOf('10.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'Skin/Body',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'Wound Detail',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'IsValid',
        htmlid__c = 'IsValid',
        Field_Type__c = 'Hidden',
        Field_Sub_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('0.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'Skin/Body',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'Wound Detail',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'isRepeatable',
        htmlid__c = 'isRepeatable',
        visible__c = false,
        Field_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('99.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'isRepeatable',
        htmlid__c = 'isRepeatable',
        visible__c = false,
        Field_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('99.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'IsValid',
        htmlid__c = 'IsValid',
        Field_Type__c = 'Hidden',
        Field_Sub_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('0.00')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c='ErrorMsg',
        htmlid__c='ErrorMsg',
        Field_Type__c='Hidden',
        Field_Sub_Type__c='String',
        Field_Sequence__c=Decimal.valueOf('0.10')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Boolean_Checkbox',
        htmlid__c = 'Boolean_Checkbox',
        Field_Type__c = 'Boolean',
        Field_Sub_Type__c = 'Checkbox',
        Field_Sequence__c = Decimal.valueOf('1.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = true,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Boolean_Dropdown',
        htmlid__c = 'Boolean_Dropdown',
        Field_Type__c = 'Boolean',
        Field_Sub_Type__c = 'Dropdown',
        Field_Sequence__c = Decimal.valueOf('2.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        length__c = 3000,
        Field_Name__c = 'String_3000',
        htmlid__c = 'String_3000',
        Field_Type__c = 'String',
        Field_Sequence__c = Decimal.valueOf('3.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'String_300',
        htmlid__c = 'String_300',
        Field_Type__c = 'String',
        Field_Sequence__c = Decimal.valueOf('3.1')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Double',
        htmlid__c = 'Double',
        Field_Type__c = 'Double',
        Field_Sequence__c = Decimal.valueOf('4.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Int',
        htmlid__c = 'Int',
        Field_Type__c = 'Int',
        Field_Sequence__c = Decimal.valueOf('5.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'DropDown',
        htmlid__c = 'DropDown',
        Field_Type__c = 'DropDown',
        Field_Sequence__c = Decimal.valueOf('6.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Date',
        htmlid__c = 'Date',
        Field_Type__c = 'Date',
        Field_Sequence__c = Decimal.valueOf('7.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Datetime',
        htmlid__c = 'Datetime',
        Field_Type__c = 'Datetime',
        Field_Sequence__c = Decimal.valueOf('8.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = true,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Multiselect_Checkbox',
        htmlid__c = 'Multiselect_Checkbox',
        Field_Type__c = 'Multiselect',
        Field_Sub_Type__c = 'Checkbox',
        Field_Sequence__c = Decimal.valueOf('9.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Multiselect',
        htmlid__c = 'Multiselect',
        Field_Type__c = 'Multiselect',
        Field_Sequence__c = Decimal.valueOf('10.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'BodyMap',
        htmlid__c = 'BodyMap',
        Field_Type__c = 'BodyMap',
        Field_Sequence__c = Decimal.valueOf('11.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Image',
        htmlid__c = 'Image',
        Field_Type__c = 'Image',
        field_sub_type__c= 'Image',
        Field_Sequence__c = Decimal.valueOf('12.0')));

        testEvals.add(new Eval__c(Eval_Type__c = evlTyps[3].id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Slider',
        htmlid__c = 'Slider',
        Field_Type__c = 'Slider',
        Field_Sequence__c = Decimal.valueOf('10.0')));

        insert testEvals;

        list < eval_drop_down__c > dropdowns = new list < eval_drop_down__c > ();
        //create eval_drop_down__c
        for (eval__c eval: [Select Id from Eval__c where Category__c = 'TEST' and (Field_Type__c = 'DropDown' Or Field_Type__c = 'Multiselect')] ) {
            dropdowns.add(new eval_drop_down__c(What_Id_Object__c = 'Eval__c', whatid__c = eval.id, option_name__c = 'TEST', option_value__c = 'TEST'));
            dropdowns.add(new eval_drop_down__c(What_Id_Object__c = 'Eval__c', whatid__c = eval.id, option_name__c = 'TEST1', option_value__c = 'TEST1'));
        }
        insert dropdowns;

    }

}